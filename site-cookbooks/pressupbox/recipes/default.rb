#
# Cookbook Name:: pressupbox
# Recipe:: default
#
# Copyright 2012, David Laing
#
# Licensed under Apache v2
#

####################
# Make sure the hostname is set from the :set_fqdn attribute
####################
include_recipe "hostname"

####################
# Memory allocation
####################
class Chef::Recipe
  include MemoryAllocation
end

APACHE_PROCESS_MEMORY   = 25                    #average size of resident memory used per apache process
memory_total = get_available_memory(node) 
memory_used = {}
memory_used['misc_and_cache'] = memory_total * 0.3 
memory_used['nginx']          = node["cpu"]["total"]  # given 1 nginx process / CPU and ~1MB / process
memory_used['mysql']          = 150                   # TODO - what causes this to change?
memory_used['postfix']        = 15  

memory_used['apache_public']  = get_memory_remaining(memory_total, memory_used)

####################
# Apache settings
####################
max_servers = (memory_used['apache_public'] / APACHE_PROCESS_MEMORY).round
node.set["apache"]["prefork"]["serverlimit"] = max_servers
node.set["apache"]["prefork"]["maxclients"] = max_servers
node.set["apache"]["prefork"]["startservers"] = (max_servers / 2).round
node.set["apache"]["prefork"]["minspareservers"] = 5  # Apache will start new servers when fewer than this number are idle
node.set["apache"]["prefork"]["maxspareservers"] = 10 # Apache will kill servers when more than this number are idle

node.set["apache"]["listen_ports"] = [ "81" ]

####################
# Nginx settings
####################
node.set["nginx"]["server_names_hash_bucket_size"] = 2048

####################
# Mysql settings
####################
node.set["mysql"]["bind_address"] = "127.0.0.1"

####################
# Postfix settings
####################
node.set["postfix"]["mydomain"] = node["domain"]

####################
# Time
####################
node.set["tz"] = 'UTC'

####################
# Run recipies to configure all the parts of the system
####################

include_recipe "apt"
include_recipe "build-essential"
include_recipe "runit"
include_recipe "htop"
include_recipe "timezone"
include_recipe "unarchivers"
include_recipe "multitail"

include_recipe "postfix"
include_recipe "wrapper_mysql::server"

include_recipe "wrapper_php"
include_recipe "wrapper_php::module_apc"
include_recipe "wrapper_php::module_mysql"

include_recipe "wrapper_apache2::default"
include_recipe "wrapper_apache2::mod_php5"
include_recipe "wrapper_apache2::mod_rpaf"

include_recipe "apache2-mpm-itk::default"

include_recipe "nginx"
include_recipe "wrapper_nginx::setup_reverse_proxy_cache"

include_recipe "app_containers"