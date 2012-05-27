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
      if (not site['db_name'].startswith("#{node['app_name']}_")) then
        Chef::Log.error "db_name provided: (#{site['db_name']}) MUST start with app_container_name: #{node['app_name']}_"
        throw error
      end
      execute "Create mysql DB: #{site['db_name']}" do
        command "mysql --execute \"'CREATE DATABASE IF NOT EXISTS #{site['db_name']};'\""
        action :run
      end
    end

    # =========================
    #  Setup apache vhost
    # =========================
    if site.has_key?('upload_folders') then upload_folders = site['upload_folders'] else upload_folders = [] end
    if site.has_key?('aliases') then aliases = site['aliases'] else aliases = [] end
    template "#{node['home_dir']}/etc/apache2/sites-available/#{site['server_name']}" do
      source "etc/apache2/#{site['type']}.erb"
      action :create
      owner "root"
      group "root"
      variables(:params => {  
        :host_name => node['host_name'], 
        :server_name => site['server_name'],
        :aliases => aliases, 
        :home_dir => node['home_dir'],
        :web_root => "#{node['home_dir']}/www/#{site['web_root']}",
        :upload_folders => upload_folders
       } )
      mode 0755
    end

    execute "enable #{site['server_name']} site" do
      command "#{node['home_dir']}/bin/a2ensite-#{node['app_name']} #{site['server_name']}"
      action :run
    end

    # =========================
    #  Setup app reverse proxy
    # =========================
    if site.has_key?('admin_ips') then admin_ips = site['admin_ips'] else admin_ips = ["127.0.0.1"] end
    template "#{node['home_dir']}/etc/nginx/sites-available/#{site['server_name']}" do
      source "/etc/nginx/#{site['type']}.erb"
      action :create
      owner "root"
      group "root"
      variables(:params => { 
        :server_name => site['server_name'], 
        :aliases => aliases,
        :app_name => node['app_name'], 
        :admin_ips => admin_ips,
        :apache_port => node['apache_port'], 
        :admin_apache_port => node['admin_apache_port'], 
        :home_dir => node['home_dir'],
        :web_root => "#{node['home_dir']}/www/#{site['web_root']}"
      } )
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
    execute "change folder permissions to 0750 for #{File.join(node['home_dir'],"www",site['web_root'])} " do
      command "find #{File.join(node['home_dir'],"www",site['web_root'])} -type d -exec chmod 0750 {} \\;"
      returns [0,1]  #errors are allowed because in the dev setup where this is a shared nfs folder, you cannot chown / chmod
      action :run
    end
    execute "change file permissions to 0640 for #{File.join(node['home_dir'],"www",site['web_root'])}" do
      command "find #{File.join(node['home_dir'],"www",site['web_root'])} -type f -exec chmod 0640 {} \\;"
      returns [0,1]  #errors are allowed because in the dev setup where this is a shared nfs folder, you cannot chown / chmod
      action :run
    end
    
    #www-data group needs write permissions to the "upload_folders" so image uploads can happen
    upload_folders.each do |upload_folder|
      execute "give www-data group +rw to #{File.join(node['home_dir'],"www",site['web_root'],upload_folder)}" do
        command "chmod g+rwx -R #{File.join(node['home_dir'],"www",site['web_root'],upload_folder)}"
        returns [0,1]  #errors are allowed because in the dev setup where this is a shared nfs folder, you cannot chown / chmod
        action :run
      end
    end

  end #hosting_setup_conf['sites']
end #hosting_setup_files

service "apache2-#{node['app_name']}" do
 action [:restart ]
end

service "apache2" do
 action [:restart ]
end

service "nginx" do
  action [:restart ]
end

