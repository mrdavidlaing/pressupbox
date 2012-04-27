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

hosting_setup_files = recursive_find("#{node['home_dir']}/www", 'hosting_setup.pressupbox.json')

hosting_setup_files.each do |hosting_setup_file|

  Chef::Log.info "Processing #{hosting_setup_file}"
  hosting_setup_conf = JSON.parse(File.read(hosting_setup_file))

  hosting_setup_conf['sites'].each do |site|
    Chef::Log.info "Creating site: #{site['server_name']}"

    template "#{node['home_dir']}/etc/apache2/sites-available/#{site['server_name']}" do
      source "etc/apache2/#{site['type']}.erb"
      action :create
      owner "root"
      group "root"
      variables(:params => {  
        :host_name => node['host_name'], 
        :server_name => site['server_name'],
        :aliases => site['aliases'], 
        :home_dir => node['home_dir'],
        :web_root => "#{node['home_dir']}/www/#{site['web_root']}"
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
    template "#{node['home_dir']}/etc/nginx/sites-available/#{site['server_name']}" do
      source "/etc/nginx/#{site['type']}.erb"
      action :create
      owner "root"
      group "root"
      variables(:params => { 
        :server_name => site['server_name'], 
        :aliases => site['aliases'],
        :app_name => node['app_name'], 
        :port => node['port'], 
        :home_dir => node['home_dir'],
        :web_root => "#{node['home_dir']}/www/#{site['web_root']}"
      } )
      mode 0755
    end
 
    link "#{node['home_dir']}/etc/nginx/sites-enabled/#{site['server_name']}" do
        to "#{node['home_dir']}/etc/nginx/sites-available/#{site['server_name']}"
    end

    # =========================
    #  Fix file permissions
    # =========================
    execute "change ownership of #{node['home_dir']}/www/#{site['web_root']}" do
      command "chown -R #{node['www_user']}:#{node['www_user']} #{node['home_dir']}/www/#{site['web_root']}"
      action :run
    end
    execute "change permissions of #{node['home_dir']}/www/#{site['web_root']}" do
      command "chmod -R 775 #{node['www_user']}:#{node['www_user']} #{node['home_dir']}/www/#{site['web_root']}"
      action :run
    end

  end #hosting_setup_conf['sites']
end #hosting_setup_files

service "apache2-#{node['app_name']}" do
 action [:restart ]
end

service "nginx" do
  action [:restart ]
end


