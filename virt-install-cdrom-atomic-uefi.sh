#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='cdrom'
ISO='/guests/images/Fedora-Atomic-ostree-x86_64-25-20170124.1.iso'
ISO='/guests/images/Fedora-Atomic-ostree-x86_64-25-20170207.0.iso'
ISO='/guests/images/Fedora-Atomic-ostree-x86_64-25-20170213.0.iso'
ISO='/guests/images/Fedora-Atomic-ostree-x86_64-25-20170215.1.iso'
RAMSIZE='4096' # IN MB
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
reqpart
part pv.01 --grow
volgroup atomicos pv.01
logvol / --size=3000 --fstype="xfs" --name=root --vgname=atomicos
logvol /boot --size=300 --fstype="xfs" --name=boot --vgname=atomicos
#logvol /var/home --size=3000 --fstype="xfs" --name=home --vgname=atomicos

# For f25
ostreesetup --osname=fedora-atomic --remote=fedora-atomic --url=file:////run/install/repo/content/repo --ref=fedora-atomic/25/x86_64/docker-host --nogpg
# For f25 from upstream repo
#ostreesetup --osname=fedora-atomic --remote=fedora-atomic --url=https://kojipkgs.fedoraproject.org/atomic/25/ --ref=fedora-atomic/25/x86_64/docker-host --nogpg

services --disabled="cloud-init,cloud-config,cloud-final,cloud-init-local"

%post --erroronfail
rm -f /etc/ostree/remotes.d/fedora-atomic.conf
# For F25
ostree remote add --set=gpg-verify=false fedora-atomic https://kojipkgs.fedoraproject.org/atomic/25/ 

# Set up for overlayfs
echo 'ROOT_SIZE=9G' >>  /etc/sysconfig/docker-storage-setup
echo 'STORAGE_DRIVER=overlay2' >>  /etc/sysconfig/docker-storage-setup

%end

EOF

# Build up the virt-install command
cmd='virt-install'
cmd+=" --name $NAME"
cmd+=" --ram  $RAMSIZE"
cmd+=" --vcpus $VCPUS"
cmd+=" --disk path=${IMAGEDIR}/${NAME}.img,size=$DISKSIZE"
cmd+=" --accelerate"
cmd+=" --location $ISO"
cmd+=" --initrd-inject $KS"
cmd+=" --graphics none"
cmd+=" --force"
cmd+=" --network bridge=$BRIDGE"
cmd+=" --boot uefi"

# Variable for kernel args.
extras="console=ttyS0 inst.sshd ks=file://ks.conf"
#extras="console=ttyS0 text"

# Run the command
echo "Running: $cmd --extra-args=$extras"
$cmd --extra-args="$extras"

# Clean up tmp dir
rm -rf $TMPDIR/
