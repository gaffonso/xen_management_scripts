#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/install_and_configure_mysql51.sh | bash -s mysql_root_password
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


# Must be root to run this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# re-source /etc/profile in case previous scripts have made changes
source /etc/profile


echo
echo "------------------------------------"
echo "Installing and Configuring Mysql 5.1"
echo "------------------------------------"
echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
echo


yum -y install mysql-server
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