#!/bin/bash
#
# run with:
#   curl -s https://raw.github.com/gaffonso/xen_management_scripts/master/xen_remove_vm.sh | bash -s vm_name
# alternatively:
#   bash -c "$(curl -fsSL https://raw.github.com/gaffonso/xen_management_scripts/master/xen_remove_vm.sh)" vm_name
# TODO: get script running via github

# if called via curl, the vm_name (first argument) is $0, else $1

echo $0

#if [ $# -ne 1 -o "x$0" == "x"  -o $0 == "bash" ]; then
#  echo "Missing VM name."
#  exit 1
#fi
#VM_NAME=$1
#
#xm destroy $VM_NAME-cos63
#lvremove -f /dev/stor/$VM_NAME