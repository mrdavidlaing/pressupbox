#
# Cookbook Name:: apache2
# Recipe:: envvars 
#

theport=node[:apache][:listen_ports].map{|p| p.to_i}.uniq[0]
template "envvars" do
  path "#{node[:apache][:dir]}/envvars"
  source "etc/envvars.erb"
  owner "root"
  group node[:apache][:root_group]
  mode 0644
  backup false
  variables(:port => theport)
  notifies :restart, resources(:service => "apache2")
end