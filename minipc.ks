install
reboot
url --mirrorlist https://download.fedoraproject.org/pub/fedora/linux/releases/23/Server/x86_64/os/ 
repo --name=updates-testing --mirrorlist https://mirrors.fedoraproject.org/metalink?repo=updates-released-f23&arch=x86_64

lang en_US.UTF-8
keyboard us
rootpw  password
authconfig --enableshadow --passalgo=sha512
selinux --enforcing
timezone --utc America/New_York
bootloader --location=mbr --driveorder=sda --append="crashkernel=auto"

# Partition info
clearpart --all
autopart --type=lvm
##  zerombr
##  part biosboot --fstype=biosboot --size=1
##  part / --size=3000 --fstype=ext4 --grow
##  part /boot     --size=300  --fstype=ext4
##  part pv.000001 --size=1    --grow
##  volgroup vg_root pv.000001
##  logvol swap --name=lv_swap --vgname=vg_root --size=512 --maxsize=512
##  logvol /    --name=lv_root --vgname=vg_root --size=1   --fstype=ext4 --grow

# open up ssh
#firewall --service=ssh

%packages --instLangs=en_US
@core
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
