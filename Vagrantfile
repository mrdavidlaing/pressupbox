Vagrant::Config.run do |config|

  # Ubuntu 12.04 x64
  config.vm.box     = "ubuntu-12.04-server-amd64"
  config.vm.box_url = "https://s3-eu-west-1.amazonaws.com/ciapi-eu/ubuntu-12.04-server-amd64.box"

  config.vm.forward_port 3306, 13306 #MySQL

  config.vm.customize ["modifyvm", :id, "--memory", "512"]
  config.vm.customize ["modifyvm", :id, "--cpus", "2"]

  config.vm.network :hostonly, "33.33.33.10"

  use_nfs = !(Vagrant::Util::Platform.windows?)
  config.vm.share_folder("app_container1-www", "/data/app_containers/app_container1/www/test_repo", "samples/app_container1/www/test_repo", :nfs => use_nfs)

  config.vm.provision :chef_solo do |chef|

    chef.cookbooks_path = ["cookbooks","site-cookbooks"]
    chef.data_bags_path = ["data_bags"]
    chef.log_level      = :debug
    
    #recipes added in pressupbox-live role
    chef.add_recipe     "pressupbox::default"

    #recipes under development
    
    #chef.add_recipe     "ossec::default"
    
    #chef.add_recipe     "php::module_xdebug"
    #chef.add_recipe     "collectd"
    #chef.add_recipe     "collectd_plugins"
    #chef.add_recipe     "collectd::collectd_web"

    chef.json.merge!({
                        
                    :set_fqdn => "pressupbox-test",
                    :collectd => {:collectd_web => {:path=>"/var/local/collectd_web"} } 
    })
  end
end
