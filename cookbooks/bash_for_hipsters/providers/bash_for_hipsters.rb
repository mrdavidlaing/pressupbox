action :create do
  template "#{new_resource.home_dir}/.bashrc" do
    cookbook "bash_for_hipsters"
    source "bashrc.erb"
    action :create
    owner "#{new_resource.username}"
    group "root"
    variables(:home_dir => new_resource.home_dir)
    mode 0600
  end
end
