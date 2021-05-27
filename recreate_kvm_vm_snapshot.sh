#!/bin/bash

LOG_FILE=/tmp/snapshot.log

for vm in $(virsh list --all --name)
do
    virsh snapshot-delete $vm $vm-old-snap-name
    if [ $? -eq 0 ]; then
        echo "Snapshot for $vm successfuly deleted"
        echo
        echo "Re-creating snapshot for $vm"
        echo
        virsh snapshot-create-as $vm --name $vm-new-snap-name
        if [ $? -eq 0 ]; then
            echo "Snapshot for $vm successfuly created"
        fi
    else
        exec > >(tee -a ${LOG_FILE}) 2>&1
    fi
done
