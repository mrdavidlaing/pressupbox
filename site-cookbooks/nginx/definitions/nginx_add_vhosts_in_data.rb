# Copyright 2011, David Laing 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

define :nginx_add_vhosts_in_data do

  Chef::Log.info "Setting up vhost all vhosts in /data/*/etc/nginx/*.conf"


  template "#{node[:nginx][:dir]}/sites-available/add-vhosts-in-data.conf" do
    source "add-vhosts-in-data.conf.erb"
    owner "root"
    group "root"
    mode 0644
    backup false
    if ::File.exists?("#{node[:nginx][:dir]}/sites-enabled/add-vhosts-in-data.conf")
      notifies :restart, resources(:service => "nginx"), :immediately
    end
  end

  nginx_site "add-vhosts-in-data.conf" do
    enable enable_setting
  end

end
