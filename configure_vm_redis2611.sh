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

# install and build redis
yum install make gcc
wget http://redis.googlecode.com/files/redis-2.6.11.tar.gz -P /stor/downloads/
tar zxf /stor/downloads/redis-2.6.11.tar.gz /usr/local
/usr/local/redis-2.6.11/make
/usr/local/redis-2.6.11/make test
/usr/local/redis-2.6.11/make install


echo
echo "--------------"
echo "Setup Complete"
echo "--------------"
echo
hostname
echo
echo "JAVA_HOME: $JAVA_HOME"
echo "M2_HOME: $M2_HOME"
echo "GRAILS_HOME: $GRAILS_HOME"
echo "PATH: $PATH"
echo
redis-cli --version
echo
redis-server --version