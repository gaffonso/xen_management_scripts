#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/install_and_configure_grails201.sh | bash -s
#
# Note: Script assumes
# - vm was created using the xen_create_vm.sh script (or equivalent)
# - "update_and_configure_new_vm.sh" has been run inside this vm
# - java has been properly installed
# - logged-in as root

#set -o xtrace

# Must be root to run this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# must have java installed to run this script
if [ ! $JAVA_HOME ]; then
   echo "This script requires that java be properly installed (JAVA_HOME must be set)" 1>&2
   exit 1
fi


# re-source /etc/profile in case previous scripts have made changes
source /etc/profile


echo
echo "---------------------------------------"
echo "Installing and Configuring Grails 2.0.1"
echo "---------------------------------------"
echo


# create download folder if necessary
[ ! -f /stor/downloads ] && mkdir /stor/downloads


# install grails 2.0.1
wget http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.0.1.zip -P /stor/downloads/
unzip /stor/downloads/grails-2.0.1.zip -d /usr/local
ln -s /usr/local/grails-2.0.1 /usr/local/grails
touch /etc/profile.d/grails.sh
echo 'export GRAILS_HOME=/usr/local/grails' >> /etc/profile.d/grails.sh
source /etc/profile.d/grails.sh
echo "export PATH=${GRAILS_HOME}/bin:${PATH}" >> /etc/profile.d/grails.sh
source /etc/profile.d/grails.sh


echo
echo "--------------"
echo "Setup Complete"
echo "--------------"
echo
echo "GRAILS_HOME: $GRAILS_HOME"
echo "PATH: $PATH"
echo
grails -version