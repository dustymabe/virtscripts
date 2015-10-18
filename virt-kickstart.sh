#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='builder4'
#REMOTEKS='https://kojipkgs.fedoraproject.org//work/tasks/8051/11108051/koji-f23-build-11108051-base.ks'
#REMOTEKS='file:///guests/virtscripts/fedora-cloud-base-4d05ed6.ks'
#REMOTEKS='file:///guests/virtscripts/fedora-cloud-base-72774fc.ks.orig'
REMOTEKS='file:///guests/virtscripts/fedora-cloud-base-72774fc.ks'
LOCATION='http://dl.fedoraproject.org/pub/alt/stage/23_TC11/Cloud/x86_64/os/'
RAMSIZE='1500' # IN MB
DISKSIZE='12'  # IN GB
VCPUS='2'      # NUM of CPUs
IMAGEDIR='/guests/images'
BRIDGE='virbr0'

# Create some temporary files
TMPKS=$(mktemp)
curl $REMOTEKS > $TMPKS

# Build up the virt-install command
cmd='virt-install'
cmd+=" --name $NAME"
cmd+=" --ram  $RAMSIZE"
cmd+=" --vcpus $VCPUS"
cmd+=" --disk path=${IMAGEDIR}/${NAME}.img,size=$DISKSIZE"
cmd+=" --accelerate"
cmd+=" --location $LOCATION"
cmd+=" --initrd-inject $TMPKS"
cmd+=" --graphics none"
cmd+=" --force"
cmd+=" --noreboot"
cmd+=" --network bridge=$BRIDGE"

# Variable for kernel args.
extras="console=ttyS0 ks=file://$(basename $TMPKS) inst.sshd"
#nokill

# Run the command
echo "Running: $cmd --extra-args=$extras"
$cmd --extra-args="$extras"

# Clean up tmp dir
rm -f $TMPKS
