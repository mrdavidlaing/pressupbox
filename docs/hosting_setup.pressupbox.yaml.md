# hosting_setup.pressupbox.yaml

 * Describes the websites that are present in the repository 
 * Used by ~/bin/process_hosting-setup to generate the required config files (apache etc)
 * Must exist at the root level of the repository checked out to ~/www/{repo_name}/hosting_setup.pressupbox.yaml
 * As YAML

## Sample

    {
      "sites": [
        {
          "server_name": "mysite.com",
          "type": "wordpressmu",
          "aliases": [ 
            "*.mysite.com",
            "another_name.com", "www.another_name.com"
          ],
          "web_root": "httpdocs/mysite.com",
          "db_name": "my_app_container_mysite"
        },
        {
          "server_name": "demo.mysite.com",
          "type": "wordpress",
          "aliases": [],
          "web_root": "httpdocs/demo.mysite.com",
          "db_name": "my_app_container_demo"
        }
      ]	
    }

## Description

 * sites - array of sites that are present in the repository.
    * server_name - the primary name for the vhost
    * type - website type - wordpress|wordpressmu|default
    * aliases - array of vhost aliases for the primary server_name
    * web_root - server path, relative to repository root.
      http://{server_name}/a_file.html ->  ~/www/{repo_name}/{web_root}/a_file.html
    * db_name - name of database - prefix must be ```{app_container_name}_```