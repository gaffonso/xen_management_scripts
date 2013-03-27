#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/configure_vm_redis2611.sh | bash -s hostname
#
# Note: Script assumes
# - vm was created using the xen_create_vm.sh script (or equivalent)
# - logged-in as root

#set -o xtrace

# check params
if [ $# -ne 1 ]; then
  echo "Missing hostname."
  exit 1
fi

HOSTNAME=$1

echo
echo "--------------------------"
echo "Installing and Configuring"
echo "--------------------------"
echo "HOSTNAME: $HOSTNAME"
echo


# Must be root to run this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# update system
yum -y update


# set timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
sed -i 's|ZONE="America/New York"|ZONE="America/Los_Angeles"|' /etc/sysconfig/clock


# change hostname
hostname precor1
echo "HOSTNAME=\"${HOSTNAME}\"" >> /etc/sysconfig/network


# format and mount the storage volume
mkfs.ext3 /dev/xvdb
mkdir /stor
mount /dev/xvdb /stor
echo '/dev/xvdb       /stor       ext3    errors=remount-ro       0 0' >> /etc/fstab


# prep some folders on the storage volume
mkdir /stor/downloads
mkdir /stor/project_roots

# install make, gcc and tcl
yum -y install make gcc tcl


# download, build and install redis
ls wget http://redis.googlecode.com/files/redis-2.6.11.tar.gz -P /stor/downloads/
tar zxf /stor/downloads/redis-2.6.11.tar.gz -C /usr/local
cd /usr/local/redis-2.6.11/
make
make test
cd make install

# configure redis as a system daemon
# see... http://redis.io/topics/quickstart
cp /usr/local/redis-2.6.11/utils/redis_init_script /etc/init.d/redis_6379
mkdir /etc/redis
cp /usr/local/redis-2.6.11/redis.conf /etc/redis/6379.conf

# chkconfig: 345 20 80
# description: Starts and stops the Oracle database and listeners


mkdir -p /var/redis/6379
sed -i 's|daemonize no|daemonize yes|' /etc/redis/6379.conf
sed -i 's|pidfile /var/run/redis.pid|pidfile /var/run/redis_6379.pid|' /etc/redis/6379.conf
sed -i 's|logfile stdout|logfile /var/log/redis_6379.log|' /etc/redis/6379.conf
sed -i 's|dir ./|/var/redis/6379|' /etc/redis/6379.conf


chkconfig --levels 235 redis_6379 on




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
/etc/init.d/redis status