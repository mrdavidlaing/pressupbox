Vagrant::Config.run do |config|

  config.vm.box     = "oneiric32_base"
  config.vm.box_url = "http://files.travis-ci.org/boxes/bases/oneiric32_base.box"

  config.vm.forward_port 80, 4480

  # config.vm.customize do |vm|
  #   vm.memory_size = 768
  #   vm.cpu_count   = 2
  # end

  config.vm.provision :chef_solo do |chef|

    chef.cookbooks_path = ["cookbooks"]
    chef.data_bags_path = ["data_bags"]
    chef.log_level      = :debug
    chef.add_recipe     "apt"

  #  chef.add_recipe     "apparmor"
  #  chef.add_recipe     "htop"
  #  chef.add_recipe     "unarchivers"
  #  chef.add_recipe     "timezone"
  #  chef.add_recipe     "hostname"
#
  #  chef.add_recipe     "apache2"
  #  chef.add_recipe     "apache2::mod_php5"

    #chef.add_recipe     "nginx::install_from_package"
    #chef.add_recipe     "php"
    #chef.add_recipe     "php::module_apc"
    #chef.add_recipe     "php::module_xdebug"
    #chef.add_recipe     "php::module_mysql"
    chef.add_recipe     "app_containers"

    chef.json.merge!({
                        
                    :set_fqdn => "pressupbox-test"
                       
                    })
  end
end
