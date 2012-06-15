service "apparmor" do
  service_name "apparmor"
  restart_command "restart apparmor"
  supports :restart => true
  action :nothing
end

Chef::Log.info("Ensuring that apparmor allows mysqld access to the required folders")
template "/etc/apparmor.d/usr.sbin.mysqld" do
    source "etc/apparmor.d/usr.sbin.mysqld.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "apparmor"), :immediately
    backup 1
end

include_recipe "mysql::server"

unless FileTest.directory?(node['mysql']['data_dir'])

  service "mysql" do
      action :stop
  end

  directory node['mysql']['data_dir'] do
      owner "mysql"
      group "mysql"
      action :create
      not_if do  end
  end

  execute "move mysql data folder" do
      command "mv /var/lib/mysql #{node['mysql']['data_dir']}"
      not_if do FileTest.directory?(node['mysql']['data_dir']) end
  end

  service "mysql" do
      action :start
  end

end
