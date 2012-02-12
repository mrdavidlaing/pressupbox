Vagrant::Config.run do |config|

  config.vm.box     = "oneiric32_base"
  config.vm.box_url = "http://files.travis-ci.org/boxes/bases/oneiric32_base.box"

  config.vm.forward_port 80, 4480

  # config.vm.customize do |vm|
  #   vm.memory_size = 768
  #   vm.cpu_count   = 2
  # end

  config.vm.provision :chef_solo do |chef|
    # you can use multiple cookbook locations if necessary.
    # For example, to develop both shared OSS cookbooks and your private
    # product/company-specific ones.
    chef.cookbooks_path = ["cookbooks"]
    chef.log_level      = :debug

    chef.add_recipe     "apparmor"
    #chef.add_recipe     "htop"
    #chef.add_recipe     "unarchivers"
    chef.add_recipe     "timezone"

    #chef.add_recipe     "nginx::install_from_package"
   
    # chef.json.merge!({
    #                    :apt => {
    #                      :mirror => :ru
    #                    },
    #                    :rvm => {
    #                      :rubies  => [{ :name => "1.8.7" },
    #                                   { :name => "rbx-head", :arguments => "--branch 2.0.testing", :using => "1.8.7" },
    #                                   { :name => "jruby" },
    #                                   { :name => "1.9.2" },
    #                                   { :name => "1.9.3" },
    #                                   { :name => "rbx-head", :arguments => "-n d19 --branch 2.0.testing -- --default-version=1.9", :using => "1.9.3", :check_for => "rbx-head-d19" },
    #                                   { :name => "ruby-head" },
    #                                   { :name => "1.8.6" },
    #                                   { :name => "ree" }],
    #                      :aliases => {
    #                        "rbx"         => "rbx-head",
    #                        "rbx-2.0"     => "rbx-head",
    #                        "rbx-2.0.pre" => "rbx-head"
    #                      }
    #                    },
    #                    :mysql => {
    #                      :server_root_password => ""
    #                    },
    #                    :postgresql => {
    #                      :max_connections => 256
    #                    }
    #                  })
  end
end
