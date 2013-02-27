#!/bin/bash
#
# run with:
#   bash -c "$(curl -fsSL http://raw.github.com/5043824)" vm_name

if [ $# -ne 1 -o "x$0" == "x"  -o $0 == "bash" ]; then
  echo "Missing VM name.  Supply that as first argument"
  exit 1
fi
VM_NAME=$1

xm destroy $VM_NAME-cos63
lvremove -f /dev/stor/$VM_NAME