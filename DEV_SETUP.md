## Setting up a local PressUpBox DEV server using vagrant

So, you want to extend PressupBox or run a local pressupbox on your laptop.  This documents explains how.

### Prerequisits:

1. A working vagrant setup - read through the [Vagrant getting started docs](http://docs.vagrantup.com/v1/docs/getting-started/index.html) to get your vagrant environment setup.
1. A clone of this repo on your local filesystem.

### Getting all the dependancies

In your terminal, navigate to the folder you cloned the pressupbox repo into and run `bundle`.  This will pull down all the dependancies listed in the Gemfile.

### Setting up an app_container

Make at least one app_container by creating `data_bags/apps/{your_app_container_name}.json`.  Use the `app_container1.json.sample` as a guide.

### Compiling the cookbooks

PressupBox is made up of a collection of [Chef cookbooks](http://docs.opscode.com/).  PressupBox only uses the chef-solo version of Chef, so you can ignore all the stuff about Chef server, knife etc.

PressupBox uses [Chef Librarian](https://github.com/applicationsonline/librarian#librarian-chef) to manage fetching and overriding elements of community cookbooks (`cookbooks-overrides/`) and custom cookbooks specific to just pressupbox (`cookbooks-sources/`)

So, before attempting to start your vagrant powered Pressupbox, you need to compile `cookbooks-overrides/` and `cookbooks-sources/` into `cookbooks/`

Rake is used to automate most steps.  Get a list of what's available by running `rake -T`

To compile the cookbooks, and launch your vagrant box run `rake vagrant:rebuild`

### Edit, compile, debug cycle

When changing a cookbook, make your changes to `cookbooks-overrides/` or `cookbooks-sources` (NOT `cookbooks/`), then update your pressupbox with the changes by running `rake vagrant:converge`

### Accessing your vagrant server:

Your vagrant powered PressupBox is accessable from your machine via 33.33.33.10

You can access it via ssh using `ssh {app_container_user}@33.33.33.10`

Alternately you can run `vagrant ssh` to login as the vagrant user (who has sudo rights)

