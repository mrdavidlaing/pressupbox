# ==================
#  Setup apache using mpm-itk worker
# ==================

bash "get apache2-mpm-itk package and install alongside existing apache" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  apt-get download apache2-mpm-itk
  dpkg -x /tmp/apache2-mpm-itk*.deb /tmp/apache2-mpm-itk/
  mv /tmp/apache2-mpm-itk/usr/sbin/apache2 /tmp/apache2-mpm-itk/usr/sbin/apache2-mpm-itk
  cp -R /tmp/apache2-mpm-itk/usr /
  rm -rf /tmp/apache2-mpm-itk/usr
  EOH
end

# Ensure the base folder exists
directory "/etc/apache2-mpm-itk" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

bash "copy main apache2ctl script, and ensure it starts the apache2-mpm-itk version" do
  user "root"
  cwd "/root"
  code <<-EOH
  cp /usr/sbin/apache2ctl /usr/sbin/apache2ctl-mpm-itk
  sed -i 's/\\/usr\\/sbin\\/apache2/\\/usr\\/sbin\\/apache2-mpm-itk/' /usr/sbin/apache2ctl-mpm-itk
  EOH
end

link "/bin/apache2ctl-mpm-itk" do
    to "/usr/sbin/apache2ctl-mpm-itk"
end

bash "setup as separate service" do
  user "root"
  cwd "/root"
  code <<-EOH
  cp /etc/init.d/apache2 /etc/init.d/apache2-mpm-itk
  sed -i 's/\\/usr\\/sbin\\/apache2ctl/\\/usr\\/sbin\\/apache2ctl-mpm-itk/' /etc/init.d/apache2-mpm-itk
  EOH
end

template "/etc/apache2-mpm-itk/apache2.conf" do
  source "etc/apache2-mpm-itk/apache2.conf.erb"
  action :create
  owner "root"
  group "root"
  mode 0640
end

template "/etc/apache2-mpm-itk/ports.conf" do
  source "etc/apache2-mpm-itk/ports.conf.erb"
  action :create
  owner "root"
  group "root"
  mode 0640
end

%w{httpd.conf magic}.each do |conf|
  link "/etc/apache2-mpm-itk/#{conf}" do
    to "/etc/apache2/#{conf}"
  end
end

link "/etc/apache2-mpm-itk/sites-enabled" do
    to "/etc/apache2/sites-enabled"
end

directory "/var/log/apache2-mpm-itk" do
  owner "root"
  group "adm"
  mode "0750"
  action :create
  recursive true
end

link "/etc/apache2-mpm-itk/mods-available" do
    to "/etc/apache2/mods-available"
end

directory "/etc/apache2-mpm-itk/mods-enabled" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

# enable mods - we want all the mods that the standard apache2 installation has
execute "copy all the mods that the standard apache2 installation has" do
  command "cp -d /etc/apache2/mods-enabled/* /etc/apache2-mpm-itk/mods-enabled"
  action :run
end

#%w{env mime authz_host dir status rewrite php5 rpaf}.each do |mod|
#  execute "a2enmod-mpm-itk #{mod}" do 
#    command "/bin/a2enmod-mpm-itk #{mod}" 
#    action :run
#  end
#end

link "/etc/apache2-mpm-itk/conf.d" do
    to "/etc/apache2/conf.d"
end

# *** not sure this is necessary
#set the apache server name 
# "/etc/apache2-mpm-itk/conf.d/server_name" do
#  source "etc/apache2-mpm-itk/conf.d/server_name.erb"
#  action :create
#  owner "root"
#  group "root"
#  mode 0755
#end

template "/etc/apache2-mpm-itk/envvars" do
  source "etc/apache2-mpm-itk/envvars.erb"
  action :create
  owner "root"
  group "root"
  variables(:port => node["apache2-mpm-itk"]["port"] )
  mode 0640
end

service "apache2-mpm-itk" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end


