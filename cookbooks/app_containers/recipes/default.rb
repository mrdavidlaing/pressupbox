Chef::Log.info "making containers"

# Load the keys of the items in the 'admins' data bag
apps = data_bag('apps')
Chef::Log.info "found apps: #{apps}"

# Ensure the base folder exists
directory "/data/app_containers" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

# Now create an admin & an www user for each app
apps.each do |app_name|
  
  app = data_bag_item('apps', app_name)
  Chef::Log.info "Creating container for app: #{app_name}"
  
  home_dir = "/data/app_containers/#{app_name}"
  admin_user = "#{app_name}"
  admin_user_uid = app['id_int']
  www_user = "#{app_name}_www"
  www_user_uid = app['id_int'] + 10000
  www_user_gid = app['id_int']
  port = app['id_int']
  aliases = app['aliases']
   
  group(www_user) do
    gid www_user_gid
  end

  #www-data user (used by nginx reverse proxy) needs access to 
  #serve static files without going via app_server (apache)
  user('www-data') do 
    gid www_user_gid
  end

  user(admin_user) do
    uid       admin_user_uid
    gid       www_user_gid
    comment   "#{app_name} admin user"
 
    home      home_dir
    shell     "/bin/bash"
    supports  :manage_home => true
  end

  user(www_user) do
    uid       www_user_uid
    gid       www_user_gid
    comment   "#{app_name} www/service user"
    
    supports  :manage_home => false
  end
 
  # admin_user & www_user should have readonly access to the home folder
  directory home_dir do
    owner "root"
    group "root"
    mode "0755"
    action :create
  end

  #Setup SSH authorized keys
  directory "#{home_dir}/.ssh" do
     action :create
     owner admin_user
     group "root"
     mode 0700
  end

  keys = app['authorized_keys']

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    action :create
    owner admin_user
    group "root"
    variables(:keys => keys)
    mode 0600
  end

  # copy in the skeleton structure
  remote_directory home_dir do
    source "skel"
    files_backup 2
    files_owner admin_user
    files_group www_user
    files_mode "0640"
    owner admin_user
    group www_user
    mode "0750"
  end

  # Bin is a collection of readonly commands the admin_user is allowed to sudo
  directory "#{home_dir}/bin" do
     action :create
     owner "root"
     group "root"
     mode 0755
  end

  #The WWW folders should be +rw for admin_user & www_user, and +r for all
  directory "#{home_dir}/www" do
     action :create
     owner admin_user
     group www_user
     mode 0775
  end

  # make a custom help file
  template "#{home_dir}/help.txt" do
    source "help.txt.erb"
    action :create
    owner "root"
    group "root"
    variables(:admin_user => admin_user, :www_user => www_user)
    mode 0644
  end

# ==================
#  Setup app apache
# ==================
  # Create links to apache control programs
  %w{apache2ctl a2ensite a2dissite a2enmod a2dismod}.each do |cmd|
    link "#{home_dir}/bin/#{cmd}-#{app_name}" do
      to "/usr/sbin/#{cmd}"
    end
  end

  link "#{home_dir}/etc/apache2/mods-available" do
      to "/etc/apache2/mods-available"
  end

  link "/etc/apache2-#{app_name}" do
      to "#{home_dir}/etc/apache2"
  end

  template "#{home_dir}/etc/apache2/envvars" do
    source "apache2-envvars.erb"
    action :create
    owner "root"
    group "root"
    variables(:port => port, :home_dir => home_dir, :user => www_user, :group => www_user)
    mode 0640
  end

  # setup as separate service 
  template "/etc/init.d/apache2-#{app_name}" do
    source "initd-apache2-instancename.erb"
    action :create
    owner "root"
    group "root"
    variables(:instance_name => app_name)
    mode 0755
  end
  
  # enable minimal set of mods
  %w{mime authz_host dir status rewrite php5}.each do |mod|
    execute "a2enmod-#{app_name} #{mod}" do 
      command "#{home_dir}/bin/a2enmod-#{app_name} #{mod}" 
      action :run
    end
  end

  #set the apache server name
  template "#{home_dir}/etc/apache2/conf.d/server_name" do
    source "etc/apache2/conf.d/server_name.erb"
    action :create
    owner "root"
    group "root"
    variables(:server_name => app_name)
    mode 0755
  end

  service "apache2-#{app_name}" do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :restart ]
  end

  # ============================
  #  Setup app management utils
  # ============================

  template "#{home_dir}/bin/tail-all-logs" do
    source "bin/tail-all-logs.erb"
    action :create
    owner "root"
    group "root"
    variables(:home_dir => home_dir)
    mode 0755
  end

  template "#{home_dir}/var/chef-solo/solo.rb" do
    source "var/chef-solo/solo.rb.erb"
    action :create
    owner "root"
    group "root"
    variables(:home_dir => home_dir)
    mode 0744
  end

  template "#{home_dir}/var/chef-solo/process-hosting_setup.runlist.json" do
    source "var/chef-solo/process-hosting_setup.runlist.json.erb"
    action :create
    owner "root"
    group "root"
    variables(:home_dir => home_dir, :app_name => app_name, :www_user => www_user, :port => port)
    mode 0744
  end

  template "#{home_dir}/bin/process-hosting_setup" do
    source "bin/process-hosting_setup.erb"
    action :create
    owner "root"
    group "root"
    variables(:home_dir => home_dir)
    mode 0755
  end

end

# Setup nginx as reverse proxy for each apache app server
template "/etc/nginx/sites-available/appcontainers_reverse_proxies" do
  source "nginx/appcontainers_reverse_proxies.erb"
  action :create
  owner "root"
  group "root"
  mode 0755
end

link "/etc/nginx/sites-enabled/appcontainers_reverse_proxies" do
  to "/etc/nginx/sites-available/appcontainers_reverse_proxies"
end

service "nginx" do
  supports :reload => true
  action [:reload ]
end


