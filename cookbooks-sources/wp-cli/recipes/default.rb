#
# Cookbook Name:: wp-cli
# Recipe:: default
#
# Copyright 2012, David Laing

include_recipe "git::default"

directory "/opt/wp-cli" do
  mode "0775"
  owner "root"
  group "root"
  action :create
  recursive true
end

git "/opt/wp-cli" do
  repository "git://github.com/wp-cli/wp-cli.git"
  reference "v0.10.0"
  enable_submodules true
  action :sync
  user "root"
  group "root"
end

bash "init wp-cli" do
	user "root"
	cwd "/opt/wp-cli"
	code <<-EOH
	utils/dev-build
	EOH
end