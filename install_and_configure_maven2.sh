#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/install_and_configure_maven2.sh | bash -s
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


# must have java installed to run this script
if [ ! $JAVA_HOME ]; then
   echo "This script requires that java be installed" 1>&2
   exit 1
fi


echo
echo "----------------------------------"
echo "Installing and Configuring Maven 2"
echo "----------------------------------"
echo


# prep some folders on the storage volume
[ ! -f /stor/downloads ] && mkdir /stor/downloads


# Install maven
# see... http://xmodulo.com/2012/05/how-to-install-maven-on-centos.html
wget http://apache.mirrors.lucidnetworks.net/maven/maven-2/2.2.1/binaries/apache-maven-2.2.1-bin.tar.gz  -P /stor/downloads/
tar xzvf /stor/downloads/apache-maven-2.2.1-bin.tar.gz -C /usr/local
ln -s /usr/local/apache-maven-2.2.1 /usr/local/maven
touch /etc/profile.d/maven.sh
echo 'export M2_HOME=/usr/local/maven' >> /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh
echo "export MAVEN_HOME=$M2_HOME" >> /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh
echo 'export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=256m"' >> /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh
echo "export PATH=${M2_HOME}/bin:${PATH}" >> /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh


echo
echo "--------------"
echo "Setup Complete"
echo "--------------"
echo
echo "NOTE: you will need to install a valid maven settings.xml file"
echo
echo "M2_HOME: $M2_HOME"
echo
mvn -version