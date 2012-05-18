# Veewee base box definitions for Vagrant

This directory contains [Veewee](https://github.com/jedi4ever/veewee) definitions to generate [base boxes](http://vagrantup.com/docs/base_boxes.html) for [Vagrant](http://vagrantup.com/).

## Scope

This is currently only used by the base box and VM maintainers. Using Veewee base box generation, while utterly convenient in principle, can still be quite involved due to the project moving fast and using bleeding edge components/dependencies as well, which specifically affects MacOS/Windows users.

## Usage

Aforementioned scope aside, usage of Veewee is actually supposed to be quite simple and boils down to the following (be sure to read the more detailed [instructions](https://github.com/jedi4ever/veewee/blob/master/doc/vagrant.md) as well though):

* list available templates    
$ `vagrant basebox templates`
* define the base box by means of a template, e.g.    
$ `vagrant basebox define 'ubuntu-12.04-server-amd64' 'ubuntu-12.04-server-amd64-packages'`
* optionally modify the generated `definition.rb/postinstall.sh/preseed.cfg`
* build the defined base box   
$ `vagrant basebox build 'ubuntu-12.04-server-amd64'`
* validate the built box    
$ `vagrant basebox validate 'ubuntu-12.04-server-amd64'`
* export the validated box    
$ `vagrant basebox export 'ubuntu-12.04-server-amd64'`

The resulting 'ubuntu-12.04-server-amd64.box' can now be used to actually built the custom VM for the use case at hand.
