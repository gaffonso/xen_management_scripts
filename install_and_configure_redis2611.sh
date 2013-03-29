#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/configure_vm_redis2611.sh | bash -s password
#
# Note: Script assumes
# - vm was created using the xen_create_vm.sh script (or equivalent)
# - logged-in as root

#set -o xtrace

# check params
if [ $# -ne 1 ]; then
  echo "Missing redis password."
  exit 1
fi
REDIS_PASSWORD=$1


echo
echo "---------------------------------------"
echo "Installing and Configuring Redis 2.6.11"
echo "---------------------------------------"
echo


# Must be root to run this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


## download, build, install and configure redis

# download
wget http://redis.googlecode.com/files/redis-2.6.11.tar.gz -P /stor/downloads/
tar zxf /stor/downloads/redis-2.6.11.tar.gz -C /usr/local

# build (and install as command-line program)
cd /usr/local/redis-2.6.11/
yum -y install make gcc tcl.x86_64     # required to build redis
make distclean      # need the distclean otherwise we get complaints about jemalloc being missing/out-of-date
make test
make install

# configure
sed -i.bak "s|# requirepass foobared|requirepass $REDIS_PASSWORD|" /usr/local/redis-2.6.11/redis.conf

# install as system service
wget https://raw.github.com/gaffonso/xen_management_scripts/master/install_and_configure_redis2611-redis-server.chkconfig -P /stor/downloads/
mv install_and_configure_redis2611-redis-server.chkconfig /etc/init.d/redis-server
chmod 755 /etc/init.d/redis-server
chkconfig --add redis-server
chkconfig --level 345 redis-server on
service redis-server start


echo
echo "--------------"
echo "Setup Complete"
echo "--------------"
echo
hostname
echo
redis-cli --version
echo
redis-server --version
echo
service redis-server status