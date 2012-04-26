Vagrant::Config.run do |config|

  config.vm.box     = "oneiric32_base"
  config.vm.box_url = "http://files.travis-ci.org/boxes/bases/oneiric32_base.box"

  config.vm.forward_port 80, 4480
  config.vm.forward_port 9000, 9000
  config.vm.forward_port 9001, 9001
  config.vm.forward_port 9002, 9002

  # config.vm.customize do |vm|
  #   vm.memory_size = 768
  #   vm.cpu_count   = 2
  # end

  config.vm.network :hostonly, "33.33.33.10"

  use_nfs = !(Vagrant::Util::Platform.windows?)
  config.vm.share_folder("home-www-labs.cityindex.com", "/data/app_containers/cityindex/www/labs.cityindex.com", "/Users/mrdavidlaing/Projects/cityindex/labs.cityindex.com", :nfs => use_nfs)

  config.vm.provision :chef_solo do |chef|

    chef.cookbooks_path = ["cookbooks"]
    chef.data_bags_path = ["data_bags"]
    chef.log_level      = :debug
 #   chef.add_recipe     "apt"

 #  chef.add_recipe     "apparmor"
 #  chef.add_recipe     "htop"
 #  chef.add_recipe     "unarchivers"
 #  chef.add_recipe     "timezone"
 #  chef.add_recipe     "hostname"
 #  chef.add_recipe     "multitail"

 chef.add_recipe     "php"
 #  chef.add_recipe     "php::module_apc"
 #  chef.add_recipe     "php::module_xdebug"
 #  chef.add_recipe     "php::module_mysql"

# chef.add_recipe     "apache2"
# chef.add_recipe     "apache2::mod_rpaf"
 chef.add_recipe     "apache2::mod_php5"

# chef.add_recipe     "nginx::install_from_package"
# chef.add_recipe     "nginx::setup_reverse_proxy_cache"
    
#   chef.add_recipe     "app_containers"
 #   chef.add_recipe     "collectd"
 #   chef.add_recipe     "collectd_plugins"
 #   chef.add_recipe     "collectd::collectd_web"


    

    chef.json.merge!({
                        
                    :set_fqdn => "pressupbox-test",
                    :php5_fpm => { :listen_socket => 100 },
                    :apache => {:listen_ports => [ "81","444" ] },
                    :collectd => {:collectd_web => {:path=>"/var/local/collectd_web"} }
                      
                    })
  end
end
