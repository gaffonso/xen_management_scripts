#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/install_and_configure_java6.sh | bash -s
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
echo "---------------------------------"
echo "Installing and Configuring Java 6"
echo "---------------------------------"


# prep some folders on the storage volume
[ ! -f /stor/downloads ] && mkdir /stor/downloads


# Install Java 6
wget --no-check-certificate --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "https://edelivery.oracle.com/otn-pub/java/jdk/6u41-b02/jdk-6u41-linux-x64-rpm.bin" -O /stor/downloads/jdk-6u41-linux-x64-rpm.bin
chmod +x /stor/downloads/jdk-6u41-linux-x64-rpm.bin
cat <<EOF | /stor/downloads/jdk-6u41-linux-x64-rpm.bin

EOF
touch /etc/profile.d/java.sh
echo 'export JAVA_HOME=/usr/java/default' >> /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo "export PATH=${JAVA_HOME}/bin:${PATH}" >> /etc/profile.d/java.sh
source /etc/profile.d/java.sh



echo
echo "--------------"
echo "Setup Complete"
echo "--------------"
echo
echo "JAVA_HOME: $JAVA_HOME"
echo "PATH: $PATH"
echo
java -version