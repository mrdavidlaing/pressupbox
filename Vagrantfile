Vagrant::Config.run do |config|

  # Opscode's Ubuntu 12.04 x64
  config.vm.box     = "opscode-ubuntu-12.04"
  config.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box"

  # Ubuntu 12.04 x64
  #config.vm.box     = "precise64"
  #config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.forward_port 3306, 13306 #MySQL

  config.vm.customize ["modifyvm", :id, "--memory", "512"]
  config.vm.customize ["modifyvm", :id, "--cpus", "2"]

  config.vm.network :hostonly, "33.33.33.10"

  use_nfs = !(Vagrant::Util::Platform.windows?)
  # config.vm.share_folder("app_container1-www", "/data/app_containers/app_container1/www/test_repo", # "samples/app_container1/www/test_repo", :nfs => use_nfs)
  # config.vm.share_folder("app_container1-forsitethemes", "/data/app_containers/forsitethemes/www/forsitethemes", # "/Users/mrdavidlaing/Projects/defries/forsitethemes", :nfs => use_nfs)
  # config.vm.share_folder("app_container1-cityindex", "/data/app_containers/cityindex/www/labs.cityindex.com", # "/Users/mrdavidlaing/Projects/cityindex/labs.cityindex.com", :nfs => use_nfs)


  config.vm.provision :chef_solo do |chef|

    chef.cookbooks_path = ["cookbooks", "site-cookbooks"]
    chef.data_bags_path = ["data_bags"]
    chef.log_level      = :debug

    chef.add_recipe     "pressupbox::default"
    
    #recipes under development
    #chef.add_recipe     "app_containers::default"
    #chef.add_recipe     "apache2-mpm-itk::default"

    #chef.add_recipe     "ossec::default"
    
    #chef.add_recipe     "php::module_xdebug"
    #chef.add_recipe     "collectd"
    #chef.add_recipe     "collectd_plugins"
    #chef.add_recipe     "collectd::collectd_web"

    chef.json.merge!({
                        
                    :set_fqdn => "pressupbox-test",
                    :mysql => {
                      "server_root_password" => "coffeebeans",
                      "server_repl_password" => "coffeebeans",
                      "server_debian_password" => "coffeebeans"
                    },
                    :collectd => {:collectd_web => {:path=>"/var/local/collectd_web"} } 
    })
  end
end
