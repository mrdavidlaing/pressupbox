require 'json'
require 'find'

def recursive_find(dir, match_string)
  results = []
  Find.find(dir) do |path|
    unless FileTest.directory?(path)
      unless File.basename(path) =~ /#{match_string}/
        Find.prune
      else
        results << path
      end
    else
      next
    end
  end
  results
end

hosting_setup_files_yaml = recursive_find("#{node['home_dir']}/www", 'hosting_setup.pressupbox.yaml')
hosting_setup_files_json = recursive_find("#{node['home_dir']}/www", 'hosting_setup.pressupbox.json') #json config files for backwards compatibility.  JSON is a valid subset of YAML

hosting_setup_files = hosting_setup_files_json | hosting_setup_files_yaml

wp_cli_sites = []

bash "clean out existing apache2 & nginx conf files prior to regenerating them" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  rm -f #{node['home_dir']}/etc/apache2/sites-enabled/*
  rm -f #{node['home_dir']}/etc/apache2/sites-available/*
  rm -f #{node['home_dir']}/etc/nginx/sites-enabled/*
  rm -f #{node['home_dir']}/etc/nginx/sites-available/*
  EOH
end

hosting_setup_files.each do |hosting_setup_file|

  Chef::Log.info "Processing #{hosting_setup_file}"
  if ( hosting_setup_file =~ /yaml$/ )then 
    hosting_setup_conf = YAML.load_file(hosting_setup_file)
  else
    hosting_setup_conf = JSON.parse(File.read(hosting_setup_file))
  end

  hosting_setup_conf['sites'].each do |site|
    Chef::Log.info "Creating site: #{site['server_name']}"
    
    # =========================
    #  Setup database
    # =========================
    if (site.has_key?('db_name')) then
      if (not site['db_name'].start_with?("#{node['app_name']}_")) then
        Chef::Log.error "db_name provided: (#{site['db_name']}) MUST start with app_container_name: #{node['app_name']}_"
        throw error
      end
      execute "Create mysql DB: #{site['db_name']}" do
        command "sudo -H mysql --execute \"CREATE DATABASE IF NOT EXISTS \\`#{site['db_name']}\\`;\""
        action :run
      end
      #Store DB => webroot map for wp-cli config
      wp_cli_sites << {:db_name => site['db_name'], :web_root => "#{node['home_dir']}/www/#{site['web_root']}" }
    end

    # =========================
    #  Setup apache vhost
    # =========================
    if site.has_key?('admin_ips') then admin_ips = site['admin_ips'] else admin_ips = ["127.0.0.1"] end
    if site.has_key?('upload_folders') then upload_folders = site['upload_folders'] else upload_folders = [] end
    if site.has_key?('aliases') then aliases = site['aliases'] else aliases = [] end
    if site.has_key?('ssl_cert') then ssl_cert = site['ssl_cert'] else ssl_cert = '' end
    if site.has_key?('ssl_cert_domain_key') then ssl_cert_domain_key = site['ssl_cert_domain_key'] else ssl_cert_domain_key = '' end
    vhost_params = {
      :ssl_cert => ssl_cert,
      :ssl_cert_domain_key => ssl_cert_domain_key,
      :host_name => node['host_name'],
      :server_name => site['server_name'],
      :aliases => aliases, 
      :admin_ips => admin_ips,
      :app_name => node['app_name'], 
      :admin_user => node['admin_user'],
      :apache_port => node['apache_port'],
      :admin_apache_port => node['admin_apache_port'], 
      :home_dir => node['home_dir'],
      :web_root => "#{node['home_dir']}/www/#{site['web_root']}",
      :upload_folders => upload_folders,
      :db_name => site['db_name'],
      :db_user => node['admin_user'],
      :db_password => node['mysql_password'],
    } 
    template "#{node['home_dir']}/etc/apache2/sites-available/#{site['server_name']}" do
      source "etc/apache2/#{site['type']}.erb"
      action :create
      owner "root"
      group "root"
      variables(:params => vhost_params, :apache_mpm_itk_user => node['admin_user'])
      mode 0755
    end
    link "#{node['home_dir']}/etc/apache2/sites-enabled/#{site['server_name']}" do
        to "../sites-available/#{site['server_name']}"
    end

    # =========================
    #  Setup app reverse proxy
    # =========================
    template "#{node['home_dir']}/etc/nginx/sites-available/#{site['server_name']}" do
      source "/etc/nginx/#{site['type']}.erb"
      action :create
      owner "root"
      group "root"
      variables(:params => vhost_params)
      mode 0755
    end
 
    link "#{node['home_dir']}/etc/nginx/sites-enabled/#{site['server_name']}" do
        to "../sites-available/#{site['server_name']}"
    end

    # =========================
    #  Fix file permissions
    # =========================
    execute "change ownership to #{node['admin_user']}:www-data for #{File.join(node['home_dir'],"www",site['web_root'])}" do
      command "chown -R #{node['admin_user']}:www-data #{File.join(node['home_dir'],"www",site['web_root'])}"
      returns [0,1]  #errors are allowed because in the dev setup where this is a shared nfs folder, you cannot chown / chmod
      action :run
    end
    execute "change file permissions to 0640 for #{File.join(node['home_dir'],"www",site['web_root'])}" do
      command "chmod -R 0640 #{File.join(node['home_dir'],"www",site['web_root'])}"
      returns [0,1]  #errors are allowed because in the dev setup where this is a shared nfs folder, you cannot chown / chmod
      action :run
    end
    execute "change folder permissions to 0750 for #{File.join(node['home_dir'],"www",site['web_root'])} " do
      command "find #{File.join(node['home_dir'],"www",site['web_root'])} -type d -exec chmod 0750 {} \\;"
      returns [0,1]  #errors are allowed because in the dev setup where this is a shared nfs folder, you cannot chown / chmod
      action :run
    end
    
    #www-data group needs write permissions to the "upload_folders" so image uploads can happen
    upload_folders.each do |upload_folder|
      execute "give www-data group +rw to #{File.join(node['home_dir'],"www",site['web_root'],upload_folder)}" do
        command "chmod g+rw -R #{File.join(node['home_dir'],"www",site['web_root'],upload_folder)}"
        returns [0,1]  #errors are allowed because in the dev setup where this is a shared nfs folder, you cannot chown / chmod
        action :run
      end
    end

  end #hosting_setup_conf['sites']
end #hosting_setup_files

# =========================
#  wp-cli config
# =========================
directory "#{node['home_dir']}/.wp-cli" do
  action :create
  owner node['admin_user']
  group 'root'
  mode 0700
end
file "#{node['home_dir']}/.wp-cli/config.yml" do
  action :create
  owner node['admin_user']
  group 'root'
  mode 0700
  content <<-EOH
require:
  - #{node['home_dir']}/.wp-cli/set_DB_env_vars.php
EOH
end
template "#{node['home_dir']}/.wp-cli/set_DB_env_vars.php" do
  source "set_DB_env_vars.php.erb"
  action :create
  owner node['admin_user']
  group 'root'
  variables(:db_user => node['admin_user'], :db_password => node['mysql_password'], :sites => wp_cli_sites)
  mode 0644
end
bash "remove old .wp-cli/wp-cli.ini (if exists)" do
  user "root"
  code <<-EOH
  rm -rf #{node['home_dir']}/.wp-cli/wp-cli.ini
EOH
end
# =========================
#  END wp-cli config
# =========================

service "apache2-mpm-itk" do
 action [:restart ]
end

service "apache2" do
 action [:restart ]
end

service "nginx" do
  action [:restart ]
end


