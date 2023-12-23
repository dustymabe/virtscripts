#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='builder1'
#REMOTEKS='https://kojipkgs.fedoraproject.org//work/tasks/8051/11108051/koji-f23-build-11108051-base.ks'
#REMOTEKS='file:///guests/virtscripts/fedora-cloud-base-4d05ed6.ks'
#REMOTEKS='file:///guests/virtscripts/fedora-cloud-base-72774fc.ks.orig'
REMOTEKS='file:///guests/sharedfolder/code/github.com/openshift/os/cloud.ks'
REMOTEKS='file:///guests/sharedfolder/code/pagure.io/fedora-kickstarts/fedora-atomic-updates.ks'
REMOTEKS='file:///guests/sharedfolder/code/pagure.io/fedora-kickstarts/fedora-atomic-updates.ks'
REMOTEKS='file:///var/b/shared/code/pagure.io/fedora-kickstarts/fedora-cloud-base.ks'
#REMOTEKS='file:///dev/shm/silverblue.ks'
#REMOTEKS='file:///guests/sharedfolder/code/pagure.io/fedora-kickstarts/foo2.ks'
#LOCATION='/guests/images/Fedora-Silverblue-ostree-x86_64-29-20180905.n.0.iso'
#LOCATION='/guests/images/Fedora-AtomicWorkstation-ostree-x86_64-28_Beta-1.3.iso'
#LOCATION='http://dl.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/x86_64/os/'
#LOCATION='http://kojipkgs.fedoraproject.org/compose/branched/Fedora-28-20180424.n.0/compose/Everything/x86_64/os'
#LOCATION='http://kojipkgs.fedoraproject.org/compose/branched/Fedora-28-20180424.n.0/compose/Everything/x86_64/os'
#LOCATION='https://dl.fedoraproject.org/pub/fedora/linux/releases/28/Everything/x86_64/os/'
#LOCATION='https://dl.fedoraproject.org/pub/fedora/linux/releases/28/Everything/x86_64/os/'
LOCATION='/guests/images/Fedora-AtomicHost-ostree-x86_64-29-20181011.n.0.iso'
LOCATION='/guests/images/Fedora-AtomicHost-ostree-x86_64-29-20181024.n.0.iso'
LOCATION='/guests/images/Fedora-Silverblue-ostree-x86_64-29-1.2.iso'
LOCATION='https://dl.fedoraproject.org/pub/fedora/linux/development/32/Everything/x86_64/os/'
RAMSIZE='4500' # IN MB
DISKSIZE='6'  # IN GB
DISKSIZE='12'  # IN GB
DISKSIZE='100'  # IN GB
VCPUS='2'      # NUM of CPUs
VCPUS='4'      # NUM of CPUs
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
#cmd+=" --graphics none"
cmd+=" --force"
cmd+=" --noreboot"
cmd+=" --network bridge=$BRIDGE"

# Variable for kernel args.
#extras="console=ttyS0 text ks=file://$(basename $TMPKS) inst.sshd"
#extras="ks=file://$(basename $TMPKS) inst.sshd inst.updates=http://192.168.122.1:8000/updates.img"
extras="ks=file://$(basename $TMPKS) inst.sshd"
#nokill

# Run the command
echo "Running: $cmd --extra-args=$extras"
$cmd --extra-args="$extras"
#$cmd

# Clean up tmp dir
rm -f $TMPKS
