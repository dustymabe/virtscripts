#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='cdrom'
#ISO='/home/dustymabe/Desktop/Fedora-20-x86_64-DVD.iso'
#ISO='/guests/CentOS-7.0-1406-x86_64-DVD.iso'
#ISO='/guests/rhel-server-7.0-x86_64-dvd.iso'
ISO='/guests/images/Fedora-Server-DVD-x86_64-23_Alpha.iso'
ISO='/guests/images/Fedora-Server-DVD-x86_64-23_TC11.iso'
RAMSIZE='1500' # IN MB
DISKSIZE='12'  # IN GB
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

# Build up the virt-install command
cmd='virt-install'
cmd+=" --name $NAME"
cmd+=" --ram  $RAMSIZE"
cmd+=" --vcpus $VCPUS"
cmd+=" --disk path=${IMAGEDIR}/${NAME}.img,size=$DISKSIZE"
cmd+=" --accelerate"
cmd+=" --location $ISO"
cmd+=" --initrd-inject $KS"
#cmd+=" --graphics none"
cmd+=" --force"
cmd+=" --network bridge=$BRIDGE"

# Variable for kernel args.
extras="console=ttyS0 inst.sshd ks=file://ks.conf"
extras="inst.sshd ks=file://ks.conf"

# Run the command
echo "Running: $cmd --extra-args=$extras"
$cmd --extra-args="$extras"

# Clean up tmp dir
rm -rf $TMPDIR/
