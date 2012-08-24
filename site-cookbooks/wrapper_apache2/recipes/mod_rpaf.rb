if platform?("debian", "ubuntu")
  package "libapache2-mod-rpaf"
end

apache_module "rpaf"