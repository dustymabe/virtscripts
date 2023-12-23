#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='cdrom'
ISO='/var/b/images/Fedora-Server-dvd-x86_64-36-1.5.iso'
#ISO='/var/b/images/rhel-server-7.7-x86_64-dvd.iso'
RAMSIZE='4500' # IN MB
DISKSIZE='300'  # IN GB
VCPUS='2'      # NUM of CPUs
IMAGEDIR='/var/b/libvirt-manual-pool/'
BRIDGE='virbr0'

# Create some temporary files
TMPDIR=$(mktemp -d)
KS="${TMPDIR}/ks.conf"

# Populate the ks file
cat <<EOF > $KS
install
cdrom
#reboot
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
part / --size=3000 --fstype=ext4 --grow
#   part /boot     --size=300  --fstype=ext4
#   part pv.000001 --size=1    --grow
#   volgroup vg_root --pesize=4096 pv.000001
#   logvol swap --name=lv_swap --vgname=vg_root --size=512 --maxsize=512
#   logvol /    --name=lv_root --vgname=vg_root --size=1   --fstype=ext4 --grow 

# open up ssh
#firewall --service=ssh

%packages --instLangs=en_US
@core
qemu-guest-agent
%end

%pre
#####!/bin/bash
####while true; do
####    if [ -f /continue ]; then break; fi
####    sleep 5
####    date
####done
%end

%post
%end

EOF

#KS="${PWD}/bug1879690.ks"

# Build up the virt-install command
cmd='virt-install'
cmd+=" --name $NAME"
cmd+=" --ram  $RAMSIZE"
cmd+=" --vcpus $VCPUS"
#cmd+=" --disk path=${IMAGEDIR}/${NAME}.img,size=$DISKSIZE"
cmd+=" --disk size=$DISKSIZE,bus=scsi"
cmd+=" --accelerate"
cmd+=" --location $ISO"
#cmd+=" --cdrom $ISO"
cmd+=" --initrd-inject $KS"
#cmd+=" --graphics none"
cmd+=" --force"
cmd+=" --network bridge=$BRIDGE"
#cmd+=" --noreboot"
#cmd+=" --boot uefi"
cmd+=" --boot menu=on,useserial=on"

# Variable for kernel args.
extras="console=ttyS0 inst.text inst.sshd ks=file://ks.conf"
extras="console=ttyS0 inst.text inst.sshd ks=file://bug1879690.ks"

# Run the command
echo "Running: $cmd --extra-args=$extras"
#$cmd --extra-args="$extras"
$cmd

# Clean up tmp dir
rm -rf $TMPDIR/
