#This recipe moves the mysql data_dir (if it hasn't already been moved)

new_data_dir = "/data/mysql"

if FileTest.directory?(new_data_dir)
  #even if it has already been moved, make sure all the other recipes know where the new location is
  node.set["mysql"]["data_dir"] = new_data_dir
else

  #ensure apparmor allows new data dir location
  service "apparmor" do
    supports [ :stop, :restart, :start ]
    action :nothing
  end

  template "/etc/apparmor.d/usr.sbin.mysqld" do
      source "etc/apparmor.d/usr.sbin.mysqld.erb"
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, "service[apparmor]", :immediately
  end

  service "mysql" do
      action :stop
  end

  execute "update my.cnf mysql data_dir" do
    command "sed -i 's/var\\/lib\\/mysql/data\\/mysql/' #{node['mysql']['conf_dir']}/my.cnf"
  end

  directory new_data_dir do
      owner "mysql"
      group "mysql"
      action :create
      recursive true
  end

  execute "move mysql data folder" do
      command "cp -R --preserve /var/lib/mysql/* #{new_data_dir}"
  end

  execute "restart mysql" do
     command "sudo service mysql start"
  end


	ruby_block 'Save updated mysql_data dir for next run' do
	  block do
	    node.set["mysql"]["data_dir"] = new_data_dir
	    node.save
	  end
	  only_if { Chef::Config[:solo] }
	end

end