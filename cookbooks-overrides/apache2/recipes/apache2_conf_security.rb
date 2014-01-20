#
# Cookbook Name:: apache2
# Recipe:: apache2_conf_security
#

case node[:platform]
when "debian", "ubuntu"

  bash "change ServerSignature in /etc/apache2/conf.d/security" do
    user "root"
    code <<-EOH
    sed -i 's/ServerSignature.*/ServerSignature Off/' /etc/apache2/conf.d/security
    EOH
  end

end