#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/install_and_configure_subversion16.sh | bash -s
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
echo "-------------------------------------------"
echo "Installing and Configuring Subversion 1.6"
echo "-------------------------------------------"
echo


# install subversion (1.6)
yum -y install subversion


echo
echo "--------------"
echo "Setup Complete"
echo "--------------"
echo
svn --version
