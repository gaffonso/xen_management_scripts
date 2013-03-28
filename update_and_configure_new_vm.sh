#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/update_and_configure_new_vm.sh | bash -s hostname
#
# Note: Script assumes
# - vm was created using the xen_create_vm.sh script (or equivalent)
# - logged-in as root

#set -o xtrace

# check params
if [ $# -ne 2 ]; then
  echo "Missing hostname."
  exit 1
fi

HOSTNAME=$1

echo
echo "------------------------"
echo "Updating and Configuring"
echo "------------------------"
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
hostname $HOSTNAME
echo "HOSTNAME=\"${HOSTNAME}\"" >> /etc/sysconfig/network


# format and mount the storage volume
mkfs.ext3 /dev/xvdb
mkdir /stor
mount /dev/xvdb /stor
echo '/dev/xvdb       /stor       ext3    errors=remount-ro       0 0' >> /etc/fstab


echo
echo "--------------"
echo "Setup Complete"
echo "--------------"
echo
echo "hostname: $(hostname)"