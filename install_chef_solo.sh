#!/bin/bash
echo "Installing chef solo based on steps defined at http://wiki.opscode.com/display/chef/Installing+Chef+Client+on+Ubuntu+or+Debian"
echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list
mkdir -p /etc/apt/trusted.gpg.d
gpg --keyserver keys.gnupg.net --recv-keys 83EF826A
gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null
apt-get update 
apt-get install opscode-keyring # permanent upgradeable keyring
apt-get upgrade -y
echo "chef chef/chef_server_url string none" | debconf-set-selections && apt-get install chef -y

