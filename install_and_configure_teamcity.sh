#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/install_and_configure_teamcity.sh
#
# Note: Script assumes
# - vm was created using the xen_create_vm.sh script (or equivalent)
# - logged-in as root

#set -o xtrace

echo
echo "------------------------------------"
echo "Installing and Configuring Team City"
echo "------------------------------------"
echo


# Must be root to run this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# re-source /etc/profile in case previous scripts have made changes
source /etc/profile


# install Team City 7.1.4
wget http://download-ln.jetbrains.com/teamcity/TeamCity-7.1.4.tar.gz -P /stor/downloads/
tar xzvf /stor/downloads/TeamCity-7.1.4.tar.gz -C /usr/local
touch /etc/profile.d/TeamCity.sh
mkdir /stor/TeamCity/
echo "export TEAMCITY_DATA_PATH=/stor/TeamCity" >> /etc/profile.d/TeamCity.sh
echo "export PATH=/usr/local/TeamCity/bin:$PATH" >> /etc/profile.d/TeamCity.sh
source /etc/profile.d/TeamCity.sh


echo
echo "--------------"
echo "Setup Complete"
echo "--------------"
echo
hostname
echo
echo "TEAMCITY_DATA_PATH: TEAMCITY_DATA_PATH"
echo "PATH: $PATH"
echo