# require_recipe 'ruby-shadow'
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
  Chef::Log.info "Creating container for app: #{app['id']}"
  
  home_dir = "/data/app_containers/#{app['id']}"
  admin_user = "#{app['id']}"
  www_user = "#{app['id']}_www"
   
  group(www_user) do
    gid app['gid']
  end

  user(admin_user) do
    uid       app['uid']
    gid       app['gid']
    comment   "#{app['id']} admin user"
 
    home      home_dir
    supports  :manage_home => true
  end

  user(www_user) do
    uid       app['uid']+10000
    gid       app['gid']
    comment   "#{app['id']} www/service user"
    
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
  

  #Setup a var/logs folder
  # %w{var var/log}.each do |dir|
  #   directory "#{home_dir}/#{dir}" do
  #      action :create
  #      owner admin_user
  #      group www_user
  #      mode 0770
  #   end
  # end

  #The WWW folders should be +rw for admin_user & www_user, and +r for all
  directory "#{home_dir}/www" do
     action :create
     owner admin_user
     group www_user
     mode 0775
  end

# ==================
#  Setup app apache
# ==================
  # Create links to apache control programs
  %w{apache2ctl a2ensite a2dissite a2enmod a2dismod}.each do |cmd|
    link "#{home_dir}/bin/#{cmd}" do
      to "/usr/sbin/#{cmd}"
    end
  end

  link "/etc/apache2-#{app['id']}" do
      to "#{home_dir}/etc/apache2"
  end

  template "/etc/init.d/apache2-#{app['id']}" do
    source "initd-apache2-instancename.erb"
    action :create
    owner "root"
    group "root"
    variables(:instance_name => app['id'])
    mode 0755
  end

  template "#{home_dir}/etc/apache2/envvars" do
    source "apache2-envvars.erb"
    action :create
    owner "root"
    group "root"
    variables(:port =>app['uid'], :home_dir => home_dir, :user => www_user, :group => www_user)
    mode 0640
  end

end
 

