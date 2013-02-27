#!/bin/bash
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/xen_remove_vm.sh | bash -s vm_name

if [ $# -ne 1 ]; then
  echo "Missing VM name."
  exit 1
fi
VM_NAME=$1

xm destroy $VM_NAME-cos63
lvremove -f /dev/stor/$VM_NAME