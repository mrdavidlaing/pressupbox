current_dir = File.dirname(__FILE__)

file_cache_path "/var/chef-solo"
cookbook_path ["#{current_dir}/cookbooks","#{current_dir}/cookbook-overrides"]
data_bag_path "#{current_dir}/data_bags"
json_attribs "#{current_dir}/node.json"
