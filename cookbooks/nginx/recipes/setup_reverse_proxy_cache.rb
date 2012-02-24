#
# Cookbook Name:: nginx
# Recipe:: setup_reverse_proxy
#

template "#{node[:nginx][:dir]}/conf.d/cache.conf" do
  source "conf.d/cache.conf.erb"
  action :create
  owner "root"
  group "root"
  mode 0755
  notifies :reload, resources(:service => "nginx"), :delayed
end
