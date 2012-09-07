default["apache2-mpm-itk"]["dir"] = "/etc/apache2-mpm-itk"
default["apache2-mpm-itk"]["port"] = "82"

# These need to be set pulled from /etc/apache2${SUFFIX}/envvars to enable multiple apache's to run
node.set['apache2-mpm-itk']['pid_file'] = "${APACHE_PID_FILE}" 
node.set['apache2-mpm-itk']['log_dir'] = "${APACHE_LOG_DIR}"
