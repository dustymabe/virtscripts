#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='cdrom'
ISO='/guests/images/Fedora-Cloud_Atomic-x86_64-23.iso'
ISO='/guests/images/Fedora-Atomic-dvd-x86_64-24-20160712.0.iso'
ISO='/guests/images/Fedora-Atomic-dvd-x86_64-24-20160823.0.iso'

RAMSIZE='1500' # IN MB
DISKSIZE='15'  # IN GB
VCPUS='2'      # NUM of CPUs
IMAGEDIR='/guests/storagepools/manual/'
BRIDGE='virbr0'

# Create some temporary files
TMPDIR=$(mktemp -d)
KS="${TMPDIR}/ks.conf"

# Populate the ks file
cat <<EOF > $KS
install
cdrom
reboot
lang en_US.UTF-8
keyboard us
rootpw  password
authconfig --enableshadow --passalgo=sha512
selinux --enforcing
timezone --utc America/New_York
bootloader --location=mbr --driveorder=vda --append="crashkernel=auto"

# Partition info
zerombr
clearpart --all
####part raid.01 --size=300 --ondisk=vda
####part raid.02 --size=300 --ondisk=vdb
####raid /boot --level=1 --device=md0 raid.01 raid.02

####part raid.11 --size=6000 --ondisk=vda
####part raid.12 --size=6000 --ondisk=vdb
####raid pv.01 --fstype="physical volume (LVM)" --level=1 --device=md1 raid.11 raid.12

####volgroup atomicos pv.01
####logvol / --size=3000 --fstype="xfs" --name=root --vgname=atomicos

####raid1 on sda and sdb devices (full device)
####    lvm volume group vg on raid1 device
####    lvm boot with ext4 and size 500M on volume group vg
####    lvm root with ext4 and size 50G on volume group vg
part raid.01 --size=1 --grow --ondisk=vda
part raid.02 --size=1 --grow --ondisk=vdb
raid pv.01 --fstype="physical volume (LVM)" --level=1 --device=md0 raid.01 raid.02
volgroup atomicos pv.01
logvol /boot --size=500 --fstype="ext4" --name=boot --vgname=atomicos
logvol / --size=3000 --fstype="xfs" --name=root --vgname=atomicos

# For f24
#ostreesetup --osname="fedora-atomic" --remote="fedora-atomic" --url="file:////run/install/repo/content/repo" --ref="fedora-atomic/24/x86_64/docker-host" --nogpg
# For f24 from upstream repo
ostreesetup --osname="fedora-atomic" --remote="fedora-atomic" --url="http://dl.fedoraproject.org/pub/fedora/linux/atomic/24/" --ref="fedora-atomic/24/x86_64/docker-host" --nogpg

services --disabled="cloud-init,cloud-config,cloud-final,cloud-init-local"

%post --erroronfail
rm -f /etc/ostree/remotes.d/fedora-atomic.conf
# For F24
ostree remote add --set=gpg-verify=false fedora-atomic 'http://dl.fedoraproject.org/pub/fedora/linux/atomic/24/'
%end

EOF

# Build up the virt-install command
cmd='virt-install'
cmd+=" --name $NAME"
cmd+=" --ram  $RAMSIZE"
cmd+=" --vcpus $VCPUS"
cmd+=" --disk path=${IMAGEDIR}/${NAME}.img,size=$DISKSIZE"
cmd+=" --disk path=${IMAGEDIR}/${NAME}2.img,size=$DISKSIZE"
cmd+=" --accelerate"
cmd+=" --location $ISO"
cmd+=" --initrd-inject $KS"
cmd+=" --graphics none"
cmd+=" --force"
cmd+=" --network bridge=$BRIDGE"

# Variable for kernel args.
extras="console=ttyS0 inst.sshd ks=file://ks.conf"

# Run the command
echo "Running: $cmd --extra-args=$extras"
$cmd --extra-args="$extras"

# Clean up tmp dir
rm -rf $TMPDIR/
