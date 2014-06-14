#
# Cookbook Name:: wp-cli
# Recipe:: default
#
# Copyright 2012, David Laing

bash "download wp-cli 0.15.1" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget https://github.com/wp-cli/builds/raw/1d252eadc353da8e165f49e8f638e75e694ad92c/phar/wp-cli.phar
  chmod +x wp-cli.phar
  sudo mv wp-cli.phar /usr/bin/wp
  EOH
end

bash "remove old install in /opt/wp-cli (if exists)" do
  user "root"
  code <<-EOH
  rm -rf /opt/wp-cli
  EOH
end