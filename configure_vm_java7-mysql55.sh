#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/configure_vm_java7-mysql55.sh | bash -s hostname mysql_root_password
#
# Note: Script assumes
# - vm was created using the xen_create_vm.sh script (or equivalent)
# - logged-in as root

#set -o xtrace

# check params
if [ $# -ne 2 ]; then
  echo "Missing hostname and/or mysql_root_password."
  exit 1
fi

HOSTNAME=$1
MYSQL_ROOT_PASSWORD=$2

echo
echo "--------------------------"
echo "Installing and Configuring"
echo "--------------------------"
echo "HOSTNAME: $HOSTNAME"
echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
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


# install subversion (1.6)
yum -y install subversion


# install mysql server 5.5 (requires non-standard repos on ubuntu 12.04.2) and lockdown security
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum --enablerepo=remi,remi-test list mysql mysql-server
yum -y --enablerepo=remi,remi-test install mysql mysql-server
/etc/init.d/mysqld start
chkconfig --levels 235 mysqld on
cat <<EOF | /usr/bin/mysql_secure_installation

Y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
Y
Y
Y
Y
EOF
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p$MYSQL_ROOT_PASSWORD mysql


# Install Java 7
wget --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "http://download.oracle.com/otn-pub/java/jdk/7/jdk-7-linux-x64.rpm" -O /stor/downloads/jdk-7-linux-x64.rpm
rpm -Uvh /stor/downloads/jdk-7-linux-x64.rpm
echo 'export JAVA_HOME=/usr/java/default' >> ~/.bash_profile
source ~/.bash_profile


# Install maven
# see... http://xmodulo.com/2012/05/how-to-install-maven-on-centos.html
wget http://apache.mirrors.lucidnetworks.net/maven/maven-2/2.2.1/binaries/apache-maven-2.2.1-bin.tar.gz  -P /stor/downloads/
tar xzvf /stor/downloads/apache-maven-2.2.1-bin.tar.gz -C /usr/local
ln -s /usr/local/apache-maven-2.2.1 /usr/local/maven
echo 'export M2_HOME=/usr/local/maven' >> ~/.bash_profile
echo 'export PATH=${M2_HOME}/bin:${PATH}' >> ~/.bash_profile
source ~/.bash_profile


# install grails 2.0.1
wget http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.0.1.zip -P /stor/downloads/
unzip /stor/downloads/grails-2.0.1.zip -d /usr/local
ln -s /usr/local/grails-2.0.1/ /usr/local/grails
echo 'export GRAILS_HOME=/usr/local/grails' >> ~/.bash_profile
echo 'export PATH=${GRAILS_HOME}/bin:${PATH}' >> ~/.bash_profile
source ~/.bash_profile


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
svn --version
echo
java -version
echo
mvn -version
echo
grails -version