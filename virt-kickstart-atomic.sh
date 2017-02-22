#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='builder3'
#REMOTEKS='file:///guests/scripts/fedora-cloud-atomic-d86a3b5.ks'
REMOTEKS='file:///guests/sharedfolder/code/pagure.io/fedora-kickstarts/fedora-atomic.ks'
#LOCATION='http://kojipkgs.fedoraproject.org/mash/branched-20150907/23/x86_64/os/'
#LOCATION='http://kojipkgs.fedoraproject.org/mash/atomic/23/'
#LOCATION='http://dl.fedoraproject.org/pub/fedora/linux/releases/25/Everything/x86_64/os/'
LOCATION='http://192.168.122.1:8000/'
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
extras="console=ttyS0 ks=file://$(basename $TMPKS)"

# Run the command
echo "Running: $cmd --extra-args=$extras"
$cmd --extra-args="$extras"

# Clean up tmp dir
rm -f $TMPKS
