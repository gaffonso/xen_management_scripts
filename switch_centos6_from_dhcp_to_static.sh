#!/bin/sh
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/switch_centos6_from_dhcp_to_static.sh | bash -s $host_ip_addr $host_netmask $gateway_ip_addr $dns1 $dns2
#
# example:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/switch_centos6_from_dhcp_to_static.sh | bash -s 10.14.251.36 255.255.254.0 10.14.250.10 10.14.0.90 10.14.0.96
#
# Note: Script assumes
# - vm was created using the xen_create_vm.sh script (or equivalent)
# - vm was configured using configure_vm_java7-mysql55.sh (or equivalent)
# - logged-in as root

#set -o xtrace

# check params
if [ $# -ne 5 ]; then
  echo "Missing network configuration parameters."
  exit 1
fi

HOST_IP_ADDRESS=$1
HOST_NETMASK=$2
GATEWAY_IP_ADDRESS=$3
DNS1=$4
DNS2=$5

echo
echo "-----------------------------------------"
echo "Switching to Static Network Configuration"
echo "-----------------------------------------"
echo "HOST_IP_ADDRESS: $HOST_IP_ADDRESS"
echo "HOST_NETMASK: $HOST_NETMASK"
echo "GATEWAY_IP_ADDRESS: $GATEWAY_IP_ADDRESS"
echo "DNS1: $DNS1"
echo "DNS2: $DNS2"
echo


## Must be root to run this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


## Configure eth0
cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0.bkup
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE="eth0"
NM_CONTROLLED="yes"
ONBOOT=yes
TYPE=Ethernet
BOOTPROTO=static
IPADDR=$HOST_IP_ADDRESS
NETMASK=$HOST_NETMASK
EOF


## Configure default gateway
grep -q "GATEWAY=$GATEWAY_IP_ADDRESS" /etc/sysconfig/network || echo "GATEWAY=$GATEWAY_IP_ADDRESS" >> /etc/sysconfig/network


## Restart the newtwork interface
/etc/init.d/network restart


## Remove DHCP Client
kill $(cat /var/run/dhclient-eth0.pid)
yum -y remove dhclient


## Configure DNS Server
cp /etc/resolv.conf /etc/resolv.conf.bkup
cat <<EOF > /etc/resolv.conf
nameserver $DNS1
nameserver $DNS2
EOF


## Summarize
echo "Setup Complete"
echo "--------------"
echo "/etc/sysconfig/network-scripts/ifcfg-eth0..."
cat /etc/sysconfig/network-scripts/ifcfg-eth0
echo
echo "/etc/sysconfig/network..."
cat /etc/sysconfig/network
echo
echo "/etc/resolv.conf..."
cat /etc/resolv.conf
echo
echo "ifconfig..."
ifconfig
