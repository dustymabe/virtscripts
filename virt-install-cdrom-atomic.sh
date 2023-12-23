#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='cdrom'
ISO='/guests/images/Fedora-Atomic-ostree-x86_64-25-20170215.1.iso'
ISO='/guests/images/Fedora-Atomic-ostree-x86_64-25-20170220.0.iso'
ISO='/guests/images/Fedora-AtomicWorkstation-ostree-x86_64-28_Beta-1.3.iso'
#ISO='/guests/images/Fedora-AtomicHost-ostree-x86_64-Rawhide-20180308.n.2.iso'
ISO='/guests/images/Fedora-Silverblue-ostree-x86_64-Rawhide-20181019.n.0.iso'
ISO='/guests/images/Fedora-AtomicHost-ostree-x86_64-Rawhide-20181019.n.0.iso'
ISO='/guests/images/Fedora-AtomicHost-ostree-x86_64-28-20180425.0.iso'
ISO='/guests/images/Fedora-Silverblue-ostree-x86_64-29-20181018.n.1.iso'
ISO='/guests/images/Fedora-AtomicHost-ostree-x86_64-29-20181016.n.0.iso'
ISO='/guests/images/Fedora-Server-netinst-x86_64-29-20181016.n.0.iso'
ISO='/guests/images/Fedora-AtomicHost-ostree-x86_64-29-20181024.n.0.iso'
ISO='/guests/images/Fedora-AtomicHost-ostree-x86_64-29-20181025.0.iso'
RAMSIZE='4500' # IN MB
DISKSIZE='15'  # IN GB
VCPUS='2'      # NUM of CPUs
IMAGEDIR='/guests/storagepools/manual/'
BRIDGE='virbr0'

# Create some temporary files
TMPDIR=$(mktemp -d)
KS="${TMPDIR}/ks.conf"

# Populate the ks file
cat > $KS <<'EOF'
install
cdrom
poweroff
#reboot
lang en_US.UTF-8
keyboard us
rootpw  password
#authconfig line only for RHEL7
#authconfig --enableshadow --passalgo=sha512
selinux --enforcing
timezone --utc America/New_York
bootloader --location=mbr --driveorder=vda --append="crashkernel=auto ip=dhcp rd.neednet=1 $coreos_firstboot"

# Partition info
zerombr
clearpart --all
autopart --type="lvm"
#reqpart --add-boot
#part pv.01 --grow
#volgroup atomicos pv.01
#logvol / --size=3000 --fstype="xfs" --name=root --vgname=atomicos
#logvol /var/home --size=3000 --fstype="xfs" --name=home --vgname=atomicos

# For f25
#ostreesetup --osname="fedora-atomic" --remote="fedora-atomic" --url="file:////run/install/repo/content/repo" --ref="fedora-atomic/25/x86_64/docker-host" --nogpg
# For f25 from upstream repo
#ostreesetup --osname="fedora-atomic" --remote="fedora-atomic" --url="http://dl.fedoraproject.org/pub/fedora/linux/atomic/24/" --ref="fedora-atomic/24/x86_64/docker-host" --nogpg

#ostreesetup --osname="fedora" --remote="fedora" --url="file:///ostree/repo" --ref="fedora/29/x86_64/silverblue" --nogpg
ostreesetup --osname="fedora" --remote="fedora" --url="file:///ostree/repo" --ref="fedora/rawhide/x86_64/atomic-host" --nogpg

services --disabled="cloud-init,cloud-config,cloud-final,cloud-init-local,fedora-readonly"

%post --erroronfail
# https://github.com/dustymabe/ignition-dracut/pull/12
touch /boot/coreos-firstboot
> /etc/machine-id

#rm -f /etc/ostree/remotes.d/fedora-atomic.conf
# For F25
#ostree remote add --set=gpg-verify=true --gpg-import=/etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-25-primary fedora-atomic 'http://dl.fedoraproject.org/pub/fedora/linux/atomic/25/'
%end

EOF

# Build up the virt-install command
cmd='virt-install'
cmd+=" --name $NAME"
cmd+=" --ram  $RAMSIZE"
cmd+=" --vcpus $VCPUS"
#cmd+=" --disk path=${IMAGEDIR}/${NAME}.img,size=$DISKSIZE"
cmd+=" --disk path=${IMAGEDIR}/${NAME}.img,size=$DISKSIZE,bus=virtio"
cmd+=" --accelerate"
cmd+=" --location $ISO"
cmd+=" --initrd-inject $KS"
#cmd+=" --graphics none"
cmd+=" --force"
cmd+=" --network bridge=$BRIDGE"
#cmd+=" --noreboot"
#cmd+=" --boot uefi"

# Variable for kernel args.
#extras="console=ttyS0 inst.sshd ks=file://ks.conf rd.break"
#extras="console=ttyS0 ks=file://ks.conf rd.break updates=http://192.168.121.1:8000/updates.img"
#extras="console=ttyS0 ks=file://ks.conf text"
#extras="console=ttyS0 ks=file://ks.conf"
#extras="ks=file://ks.conf"
#extras="console=ttyS0 ks=file://ks.conf cmdline rd.break"
#extras="inst.updates=http://192.168.122.1:8000/updates.img"

# Run the command
echo "Running: $cmd --extra-args=$extras"
#$cmd --extra-args="$extras"
$cmd

# Clean up tmp dir
rm -rf $TMPDIR/
