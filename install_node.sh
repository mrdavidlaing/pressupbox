#!/bin/sh
##############################################################
#
# Author: Ruslan Khissamov, email: rrkhissamov@gmail.com
#
##############################################################
# Add MongoDB Package
echo 'Add MongoDB Package'
echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo 'MongoDB Package completed'
# Update System
echo 'System Update'
apt-get -y update
echo 'Update completed'
# Install help app
apt-get -y install libssl-dev git-core pkg-config build-essential curl gcc g++
# Download & Unpack Node.js - v. 0.6.5
echo 'Download Node.js - v. 0.6.5'
mkdir /tmp/node-install
cd /tmp/node-install
wget http://nodejs.org/dist/v0.6.5/node-v0.6.5.tar.gz
tar -zxf node-v0.6.5.tar.gz
echo 'Node.js download & unpack completed'
# Install Node.js
echo 'Install Node.js'
cd node-v0.6.5
./configure && make && make install
echo 'Node.js install completed'
# Install Node Package Manager
echo 'Install Node Package Manager'
curl http://npmjs.org/install.sh | sudo sh
echo 'NPM install completed'
# Install Forever
echo 'Install Forever'
npm install forever -g
echo 'Forever install completed'
# Install Cloud9IDE
echo 'Install Cloud9IDE'
git clone git://github.com/ajaxorg/cloud9.git
echo 'Cloud9IDE install completed'
# Install MongoDB
echo 'Install MongoDB'
apt-get -y install mongodb-10gen
echo 'MongoDB install completed.'
# Install Redis
echo 'Install Redis'
cd /tmp
mkdir redis && cd redis
wget http://redis.googlecode.com/files/redis-2.4.2.tar.gz
tar -zxf redis-2.4.2.tar.gz
cd redis-2.4.2
make && make install
wget https://github.com/ijonas/dotfiles/raw/master/etc/init.d/redis-server
wget https://github.com/ijonas/dotfiles/raw/master/etc/redis.conf
mv redis-server /etc/init.d/redis-server
chmod +x /etc/init.d/redis-server
mv redis.conf /etc/redis.conf
useradd redis
mkdir -p /var/lib/redis
mkdir -p /var/log/redis
chown redis.redis /var/lib/redis
chown redis.redis /var/log/redis
update-rc.d redis-server defaults
echo 'Redis install completed. Run "sudo /etc/init.d/redis-server start"'

