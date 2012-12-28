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

node.set["apache"]["php5"]["upload_max_filesize"] = "10M"
node.set["apache"]["php5"]["post_max_size"] = "12M"       #must be bigger than upload_max_filesize

####################
# Nginx settings
####################
node.set["nginx"]["server_names_hash_bucket_size"] = 2048
node.set["nginx"]["variables_hash_max_size"] = 2048
node.set["nginx"]["variables_hash_bucket_size"] = 512
node.set["nginx"]["client_max_body_size"] = "10m"

####################
# Mysql settings
####################
node.set["mysql"]["bind_address"] = "127.0.0.1"
#Machines with less than 1GB RAM should use low memory settings for MySQL
if memory_total <= 1000
	node.set["mysql"]["tunable"]["key_buffer"] = "16M"
	node.set["mysql"]["tunable"]["thread_stack"] = "128K"
	node.set["mysql"]["tunable"]["innodb_buffer_pool_size"] = "16M"
else
	node.set["mysql"]["tunable"]["key_buffer"] = "256M"
	node.set["mysql"]["tunable"]["thread_stack"] = "256K"
	node.set["mysql"]["tunable"]["innodb_buffer_pool_size"] = "128M"
end

####################
# Postfix settings
####################
#force postfix to use the hostname that will get set to node["set_fqdn"] by the hostname recipe
node.set['postfix']['myhostname'] = node["set_fqdn"]  
node.set['postfix']['mydomain']   = /^(?<hostname>[^.]+)\.(?<domain>.+)/.match(node["set_fqdn"])[:domain]

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
include_recipe "mysql::server"

include_recipe "php"
include_recipe "php::module_apc"
include_recipe "php::module_mysql"
include_recipe "php::module_curl"

include_recipe "apache2::default"
include_recipe "apache2::envvars"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_php5_max_upload_filesize"
include_recipe "apache2::mod_rpaf"

include_recipe "apache2-mpm-itk::default"

include_recipe "nginx"
include_recipe "nginx::setup_reverse_proxy_cache"

include_recipe "wp-cli"
include_recipe "app_containers"