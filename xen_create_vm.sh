#!/bin/bash
#
# run with:
#   bash -c "$(curl -fsSL http://raw.github.com/5043824)" vm_name

if [ $# -ne 1 -o "x$0" == "x"  -o $0 == "bash" ]; then
  echo "Missing VM name.  Supply that as first argument"
  exit 1
fi

VM_NAME=$1

lvcreate -L100G -n $VM_NAME stor      # 100gb storage volume in volume group "stor"
cp /stor/vms/stacklet_images/centos.6-3.x86-64.20120709.img /stor/vms/${VM_NAME}_centos.6-3.x86-64.20120709.img
cp /stor/vms/stacklet_images/centos.6-3.x86-64.20120709.pygrub.cfg /stor/vms/${VM_NAME}_centos.6-3.x86-64.20120709.pygrub.cfg
sed -i 's|memory = 512|memory = 2048|' /stor/vms/${VM_NAME}_centos.6-3.x86-64.20120709.pygrub.cfg
sed -i 's|name = "centos.6-3.x86-64.20120709"|name = "${VM_NAME}-cos63"|' /stor/vms/${VM_NAME}_centos.6-3.x86-64.20120709.pygrub.cfg
sed -i "s|'file:/var/stacklet/centos.6-3.x86-64.20120709.img,xvda,w'|'file:/stor/vms/${VM_NAME}_centos.6-3.x86-64.20120709.img,xvda,w', 'phy:/dev/stor/${VM_NAME},xvdb,w'|" /stor/vms/${VM_NAME}_centos.6-3.x86-64.20120709.pygrub.cfg
echo "vcpus = 2" >> /stor/vms/${VM_NAME}_centos.6-3.x86-64.20120709.pygrub.cfg
echo "maxvcpus = 8" >> /stor/vms/${VM_NAME}_centos.6-3.x86-64.20120709.pygrub.cfg
xm create /stor/vms/${VM_NAME}_centos.6-3.x86-64.20120709.pygrub.cfg
