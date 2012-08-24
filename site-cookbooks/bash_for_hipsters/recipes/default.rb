#
# Cookbook Name:: bash_for_hipsters
# Recipe:: default
#
# Copyright 2012, David Laing

# License: Apache v2
#

  # Install shared files
  remote_directory "/var/local/bash_for_hipsters" do
    source "var/local/bash_for_hipsters"
    overwrite true
    files_owner 'root'
    files_group 'root'
    files_mode "0755"
    owner 'root'
    group 'root'
    mode "0755"
  end