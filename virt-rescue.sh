#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='rescue'
ISO='/guests/images/Fedora-Server-DVD-x86_64-23_Alpha.iso'
RAMSIZE='1500' # IN MB
DISKSIZE='12'  # IN GB
VCPUS='2'      # NUM of CPUs
BRIDGE='virbr0'
#DISK='/guests/images/builder3.img'
DISK='/guests/manualstoragepool/foo.raw'

# Build up the virt-install command
cmd='virt-install'
cmd+=" --name $NAME"
cmd+=" --ram  $RAMSIZE"
cmd+=" --vcpus $VCPUS"
cmd+=" --disk path=$DISK"
cmd+=" --accelerate"
cmd+=" --location $ISO"
cmd+=" --graphics none"
cmd+=" --force"
cmd+=" --network bridge=$BRIDGE"

# Variable for kernel args.
extras="console=ttyS0 rescue"

# Run the command
echo "Running: $cmd --extra-args=$extras"
$cmd --extra-args="$extras"
