#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/configure_vm_java7-mysql55.sh | bash -s mysql_root_password
#
# Note: Script assumes
# - vm was created using the xen_create_vm.sh script (or equivalent)
# - the script "update_and_configure_new_vm.sh" has been run inside this vm
# - logged-in as root

#set -o xtrace

# check params
if [ $# -ne 1 ]; then
  echo "Missing mysql_root_password."
  exit 1
fi
MYSQL_ROOT_PASSWORD=$1


echo
echo "--------------------------"
echo "Installing and Configuring"
echo "--------------------------"
echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
echo


# Must be root to run this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# prep some folders on the storage volume
mkdir /stor/downloads
mkdir /stor/project_roots


# Install Java 7
wget --no-check-certificate --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "https://edelivery.oracle.com/otn-pub/java/jdk/7u17-b02/jdk-7u17-linux-x64.rpm" -O /stor/downloads/jdk-7u17-linux-x64.rpm
rpm -Uvh /stor/downloads/jdk-7u17-linux-x64.rpm
touch /etc/profile.d/java.sh
echo 'export JAVA_HOME=/usr/java/default' >> /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo "export PATH=${JAVA_HOME}/bin:${PATH}" >> /etc/profile.d/java.sh
source /etc/profile.d/java.sh


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


# install grails 2.0.1
wget http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.0.1.zip -P /stor/downloads/
unzip /stor/downloads/grails-2.0.1.zip -d /usr/local
ln -s /usr/local/grails-2.0.1 /usr/local/grails
touch /etc/profile.d/grails.sh
echo 'export GRAILS_HOME=/usr/local/grails' >> /etc/profile.d/grails.sh
source /etc/profile.d/grails.sh
echo "export PATH=${GRAILS_HOME}/bin:${PATH}" >> /etc/profile.d/grails.sh
source /etc/profile.d/grails.sh


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
echo "Hostname: $(hostname)"
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