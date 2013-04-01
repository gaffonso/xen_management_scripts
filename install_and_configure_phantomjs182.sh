#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/install_and_configure_phantomjs190.sh | bash -s
#
# Note: Script assumes
# - vm was created using the xen_create_vm.sh script (or equivalent)
# - the script "update_and_configure_new_vm.sh" has been run inside this vm
# - logged-in as root

#set -o xtrace


# Must be root to run this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# re-source /etc/profile in case previous scripts have made changes
source /etc/profile


echo
echo "------------------------------------"
echo "Installing and Configuring phantomjs"
echo "------------------------------------"
echo


# install phantomjs (used by Athena)
# TODO: move this out to separate config file?
# TODO: use symlink to get phantomjs into /usr/local/bin?
wget https://phantomjs.googlecode.com/files/phantomjs-1.8.2-linux-x86_64.tar.bz2 -P /stor/downloads/
tar xpvf /stor/downloads/phantomjs-1.9.0-linux-x86_64.tar.bz2 -C /stor/downloads
yum -y install freetype.x86_64
yum -y install fontconfig.x86_64
mv /stor/downloads/phantomjs-1.9.0-linux-x86_64/bin/phantomjs /usr/local/bin
phantomjs -v


echo
echo "--------------"
echo "Setup Complete"
echo "--------------"
echo