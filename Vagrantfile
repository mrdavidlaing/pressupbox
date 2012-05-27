Vagrant::Config.run do |config|

  # Ubuntu 12.04 x64
  config.vm.box     = "ubuntu-12.04-server-amd64"
  config.vm.box_url = "https://s3-eu-west-1.amazonaws.com/ciapi-eu/ubuntu-12.04-server-amd64.box"

  config.vm.forward_port 3306, 13306 #MySQL

  config.vm.customize do |vm|
     vm.memory_size = 512
     vm.cpu_count   = 2
  end

  config.vm.network :hostonly, "33.33.33.10"

  use_nfs = !(Vagrant::Util::Platform.windows?)
  config.vm.share_folder("app_container1-www", "/data/app_containers/app_container1/www/test_repo", "samples/app_container1/www/test_repo", :nfs => use_nfs)

  config.vm.provision :chef_solo do |chef|

    chef.cookbooks_path = ["cookbooks","site-cookbooks"]
    chef.data_bags_path = ["data_bags"]
    chef.log_level      = :debug
    
    #recipes added in pressupbox-live role
    #chef.add_recipe     "apt"
    #chef.add_recipe     "runit"
#
    #chef.add_recipe     "apparmor"
    #chef.add_recipe     "hostname"
    #chef.add_recipe     "htop"
    #chef.add_recipe     "timezone"
    #chef.add_recipe     "unarchivers"
    #chef.add_recipe     "multitail"
    #chef.add_recipe      "postfix"
#
    chef.add_recipe     "apache2"
    #chef.add_recipe     "php"
    #chef.add_recipe     "php::module_apc"
    #chef.add_recipe     "php::module_mysql"
    #chef.add_recipe     "apache2::mod_php5"  
    #chef.add_recipe     "apache2::mod_rpaf"
   #
    #chef.add_recipe     "nginx::install_from_package"
    #chef.add_recipe     "nginx::setup_reverse_proxy_cache"
     
    chef.add_recipe     "app_containers"

    #recipes under development

    #chef.add_recipe     "ossec::default"
    
    #chef.add_recipe     "php::module_xdebug"
    #chef.add_recipe     "collectd"
    #chef.add_recipe     "collectd_plugins"
    #chef.add_recipe     "collectd::collectd_web"

    chef.json.merge!({
                        
                    :set_fqdn => "pressupbox-test",
                    :php5_fpm => { :listen_socket => 100 },
                    :apache => {:listen_ports => [ "81","444" ] },
                    :collectd => {:collectd_web => {:path=>"/var/local/collectd_web"} },
                    
                    "postfix" => {
                      "mydomain" => "pressupbox-test"
                    }
    })
  end
end
