#
# Cookbook Name:: pressupbox
# Recipe:: development
#
# Copyright 2012, David Laing
#
# Licensed under Apache v2
#
#  Everything as per default, plus a couple of extra dev / debugging tools
#

####################
# Include
####################
include_recipe "pressupbox::default"

####################
# Run recipies to configure all the parts of the system
####################
include_recipe "php::module_xdebug"
