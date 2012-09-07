#
# Cookbook Name:: apache2
# Recipe:: php5_max_upload_filesize
#

case node[:platform]
when "debian", "ubuntu"

  bash "change post_max_size && upload_max_filesize settings in /etc/php5/apache2/php.ini" do
    user "root"
    code <<-EOH
    sed -i 's/post_max_size.*/post_max_size = #{node["apache"]["php5"]["post_max_size"]}/' /etc/php5/apache2/php.ini
    sed -i 's/upload_max_filesize.*/upload_max_filesize = #{node["apache"]["php5"]["upload_max_filesize"]}/' /etc/php5/apache2/php.ini
    EOH
  end

end