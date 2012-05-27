# hosting_setup.pressupbox.yaml

 * Describes the websites that are present in the repository 
 * Used by ~/bin/process_hosting-setup to generate the required config files (apache etc)
 * Must exist at the root level of the repository checked out to ~/www/{repo_name}/hosting_setup.pressupbox.yaml
 * As YAML

## Sample

    # Hosting setup config for PressUpBox.  Written in YAML (http://www.yaml.org/refcard.html)
    defaults: &defaults
      type: "default"
      admin_ips:  #Use ip2cidr.com to convert IP range into CIDR notation
        - "127.0.0.1/32"
        - "33.33.33.1/32"
    sites:
      - <<: *defaults
        server_name: "default.pressupbox-test"
        web_root: "test_repo/default"
        db_name: "app_container1_default"
      - <<: *defaults
        server_name: "wordpress"
        aliases: 
          - *.wordpress.pressupbox-test
        web_root: "test_repo/default"
        upload_folders: #relative to www_root
          - "wp-content/uploads"
          - "wp-content/blogs.dir"
          - "wp-content/themes/*/cache"
        db_name: "app_container1_wordpress"

## Description
 * defaults - default values for the site elements described below
 * sites - array of sites that are present in the repository.
    * server_name - the primary name for the vhost
    * type - website type - wordpress|wordpressmu|default
    * aliases - array of vhost aliases for the primary server_name
    * web_root - server path, relative to repository root.
      http://{server_name}/a_file.html ->  ~/www/{repo_name}/{web_root}/a_file.html
    * admin_ips - range of IPs (in CIDR notation) that can access the version of apache2 
      running as the app_container "admin" user.  Effectively, accessing a site from these IPs
      gives the user more permissions to do things like upload WordPress Updates / Plugins 
    * upload_folders - array of folders (relative to web_root) that are made writable for the 
      public apache2 instance.  "Execution" of files uploaded to these folders is restricted
    * db_name - name of database - prefix must be ```{app_container_name}_```