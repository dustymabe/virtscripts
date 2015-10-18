#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='tester2'
#DISK='/guests/images/Fedora-Cloud-Base-23-20151008.x86_64.qcow2'
#DISK='/guests/images/Fedora-Cloud-Base-23_Beta_TC4-20150907.x86_64.qcow2'
#DISK='/guests/images/Fedora-Cloud-Atomic-23-20151013.x86_64.qcow2'
#DISK='/guests/images/CentOS-Atomic-Host-7.20151001-GenericCloud.qcow2'
DISK='/guests/images/Fedora-Cloud-Atomic-rawhide-20151013.x86_64.qcow2'
#DISK='/guests/images/CentOS-7-x86_64-GenericCloud-1509.qcow2'
#DISK='/guests/images/Fedora-Cloud-Base-23_TC10-20151015.x86_64.qcow2'
#DISK='/guests/images/Fedora-Cloud-Base-23_TC11-20151016.x86_64.qcow2'
#DISK='/guests/images/Fedora-Cloud-Base-23_TC9-20151013.x86_64.qcow2'
#DISK='/guests/images/Fedora-Cloud-Base-20141203-21.x86_64.qcow2'   # Official F21 Cloud Base Release
#DISK='/guests/images/Fedora-Cloud-Atomic-22-20150521.x86_64.qcow2' # Official F22 Atomic Release
#DISK='/guests/images/Fedora-Cloud-Base-22-20150521.x86_64.qcow2'   # Official F22 Cloud Base Release
DISK='/guests/images/Fedora-Cloud-Base-rawhide-20151017.x86_64.qcow2'
#DISK='/guests/images/builder4.img'
ISATOMIC=1
RAMSIZE='2048' # IN MB
DISKSIZE='20'  # IN GB
VCPUS='2'      # NUM of CPUs
BRIDGE='virbr0'
TMPISO="/guests/storagepools/manual/user-data-iso.iso${RANDOM}"
TMPDISK="/guests/storagepools/manual/$(basename ${DISK})${RANDOM}"

USERDATA='
#cloud-config
password: passw0rd
chpasswd: { expire: False }
ssh_pwauth: True
#growpart:
#  mode: off
#runcmd:
# - [ ls, -l, / ]
#OPTIONS="--selinux-enabled --storage-opt dm.datadev=/dev/atomicos/docker-data --storage-opt dm.metadatadev=/dev/atomicos/docker-meta"
'
if [ "$ISATOMIC" == "1" ]; then
    USERDATA+="
bootcmd:
- echo 'DEVS=/dev/sdb' >  /etc/sysconfig/docker-storage-setup
- echo 'VG=vgdocker' >>  /etc/sysconfig/docker-storage-setup
"
fi
METADATA='
instance-id: id-mylocal0001
local-hostname: cloudhost
'

echo "Creating user data iso $TMPISO"
pushd $(mktemp -d)
echo "$USERDATA" > user-data
echo "$METADATA" > meta-data
genisoimage -output $TMPISO -volid cidata -joliet -rock user-data meta-data
popd

echo "Creating snapshot disk $TMPDISK"
qemu-img create -f qcow2 -b $DISK $TMPDISK 10G

# Build up the virt-install command
cmd='virt-install --import'
cmd+=" --name $NAME"
cmd+=" --ram  $RAMSIZE"
cmd+=" --vcpus $VCPUS"
cmd+=" --disk path=$TMPDISK"
cmd+=" --disk path=${TMPDISK}2,size=10"
#cmd+=" --disk path=$DISK"
cmd+=" --disk path=$TMPISO"
cmd+=" --accelerate"
cmd+=" --graphics none"
cmd+=" --force"
cmd+=" --network bridge=$BRIDGE,model=virtio"

# Run the command
echo "Running: $cmd"
$cmd
