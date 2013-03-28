#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/install_and_configure_mysql55.sh | bash -s mysql_root_password
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


echo
echo "--------------"
echo "Setup Complete"
echo "--------------"