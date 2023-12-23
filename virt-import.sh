#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='tester'
DISK='/var/b/images/Fedora-Cloud-Base-26_Alpha-1.4.x86_64.qcow2'
DISK='/var/b/shared/assembler/fedora/builds/31.20200522.dev.7/x86_64/fedora-coreos-31.20200522.dev.7-qemu.x86_64.qcow2'

if [ "$1" != "" ]; then
    if [ -f "$1" ]; then
        DISK="$1"
    else
        DISK="/var/b/images/$1"
    fi
fi


RAMSIZE='4096' # IN MB
#RAMSIZE='8096' # IN MB
DISKSIZE='40'  # IN GB
VCPUS='2'      # NUM of CPUs
BRIDGE='virbr0'
TMPISO="/var/b/libvirt-manual-pool/user-data-iso.iso${RANDOM}"

CLOUD_INIT_USERDATA='
#cloud-config
password: passw0rd
chpasswd: { expire: False }
ssh_pwauth: True
ssh_authorized_keys:
 - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOLFvRYlf2UTC7lZjWO70hKGqtq6Bu+DruqJsXHE/E+v9ziTWebuEcSOZmGNRTNm7CqDoqTJgH5uPrqHfokA+kmMojefqJ9Ha9KY5l8ea9Hk88S9P4ryAW01zFkRY55xBwyIzKL9wReEFvCYTTIHOiRZbDq8PstrPwh8sXBOJhdHzLvjbuDAz7fdgH7/JBsf/FPKJ61aQkjs2a9Xfx5yC9J8wbbvLHU9myxfKPgxMLbWEnAEbFJfUGY849ZO4AiFZHYnQgQaMS1WFpEXBsA8VsFI6pzGAxCs0+7Eyy5fvUTznXdaTpr+vmMxCBllm3M3qGDVZCH04oiEKKUC+2BVQr
write_files:
 - encoding: b64
   content: CiMgVGhpcyBmaWxlIGNvbnRyb2xzIHRoZSBzdGF0ZSBvZiBTRUxpbnV4...
   owner: root:root
   path: /etc/sysconfig/foolinux
   permissions: '0644'
 - content: |
       # My new /etc/sysconfig/samba file
       SMBDOPTIONS="-D"
   path: /etc/sysconfig/samba
'

####USERDATA='#cloud-config
####ssh-authorized-keys:
#### - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOLFvRYlf2UTC7lZjWO70hKGqtq6Bu+DruqJsXHE/E+v9ziTWebuEcSOZmGNRTNm7CqDoqTJgH5uPrqHfokA+kmMojefqJ9Ha9KY5l8ea9Hk88S9P4ryAW01zFkRY55xBwyIzKL9wReEFvCYTTIHOiRZbDq8PstrPwh8sXBOJhdHzLvjbuDAz7fdgH7/JBsf/FPKJ61aQkjs2a9Xfx5yC9J8wbbvLHU9myxfKPgxMLbWEnAEbFJfUGY849ZO4AiFZHYnQgQaMS1WFpEXBsA8VsFI6pzGAxCs0+7Eyy5fvUTznXdaTpr+vmMxCBllm3M3qGDVZCH04oiEKKUC+2BVQr
####users:
####- name: "core"
####  passwd: "$6$ignUj098OpeP4zsr$E.F3GSa9mZaUIGkEKSAg5rS02YhOhdZBzjFRHDRcobWTEOjOdsIcwelrNwBtJvpz0n2EeIl.HIqdp.UNkkKmS."
####'


METADATA='
instance-id: id-mylocal0001
local-hostname: cloudhost
'

NETWORKDATA='
{
"links": [
    { // Example of physical NICs
        "id": "interface0",
        "type": "phy",
        "ethernet_mac_address": "a0:36:9f:2c:e8:80",
        "mtu": 9000
    },
],
"networks": [
    { // Standard VM VIF networking
        "id": "private-ipv4",
        "type": "ipv4",
        "link": "interface0",
        "ip_address": "10.184.0.244",
        "netmask": "255.255.240.0",
        "routes": [
            {
                "network": "10.0.0.0",
                "netmask": "255.0.0.0",
                "gateway": "11.0.0.1"
            },
        ],
        "neutron_network_id": "DA5BB487-5193-4A65-A3DF-4A0055A8C0D7"
    },
],
"services": [
    {
        "type": "dns",
        "address": "8.8.8.8"
    },
]
}
'
NETWORKDATA="
version: 1
config:
    - type: physical
      name: eth1
      mac_address: '00:16:3e:77:e2:e4'
      subnets:
      - type: static
        address: '192.168.123.129'
        netmask: '255.255.255.0'
        gateway: '192.168.123.1'
    - type: nameserver
      address:
      - '8.8.8.8'
      search:
      - 'mydomain.test'
"

IGNITION_USERDATA='
{
  "ignition": { "version": "3.0.0" },
  "systemd": {
    "units": [{
      "name": "example.service",
      "enabled": true,
      "contents": "[Service]\nType=oneshot\nExecStart=/usr/bin/echo Hello World\n\n[Install]\nWantedBy=multi-user.target"
    }]
  },
  "passwd": {
    "users": [
      {
        "name": "core",
        "sshAuthorizedKeys": [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOLFvRYlf2UTC7lZjWO70hKGqtq6Bu+DruqJsXHE/E+v9ziTWebuEcSOZmGNRTNm7CqDoqTJgH5uPrqHfokA+kmMojefqJ9Ha9KY5l8ea9Hk88S9P4ryAW01zFkRY55xBwyIzKL9wReEFvCYTTIHOiRZbDq8PstrPwh8sXBOJhdHzLvjbuDAz7fdgH7/JBsf/FPKJ61aQkjs2a9Xfx5yC9J8wbbvLHU9myxfKPgxMLbWEnAEbFJfUGY849ZO4AiFZHYnQgQaMS1WFpEXBsA8VsFI6pzGAxCs0+7Eyy5fvUTznXdaTpr+vmMxCBllm3M3qGDVZCH04oiEKKUC+2BVQr"
        ]
      }
    ]
  }
}
'

USERDATA="${CLOUD_INIT_USERDATA}"
#USERDATA="${IGNITION_USERDATA}"


USERDATAFILE=$(mktemp)
echo "$USERDATA" > $USERDATAFILE

#   echo "Creating user data iso $TMPISO"
#   pushd $(mktemp -d)
#   #mkdir -p openstack/latest/
#   #echo "$NETWORKDATA" > openstack/latest/network_data.json
#   echo "$NETWORKDATA" > network-config
#   echo "$USERDATA" > user-data
#   echo "$METADATA" > meta-data
#   #genisoimage -output $TMPISO -volid cidata -joliet -rock user-data meta-data openstack/latest/network_data.json
#   genisoimage -output $TMPISO -volid cidata -joliet -rock user-data meta-data network-config
#   popd

# Create new file to be used for ignition. This gets us around selinux
# issues and also allows us to have the file be automatically deleted
# when our process exits.
#
# NONE OF THIS WORKS
#   IGNITION_CONFIG_FILE=$(mktemp)
#   echo "$USERDATA" > $IGNITION_CONFIG_FILE
#   exec 3<>"${IGNITION_CONFIG_FILE}"
#   rm -f "${IGNITION_CONFIG_FILE}"
#   IGNITION_CONFIG_FILE=/proc/self/fd/3

#echo "Creating snapshot disk $TMPDISK"
#qemu-img create -f qcow2 -b $DISK $TMPDISK ${DISKSIZE}g
#echo "Will use backing disk $DISK"
#echo "Will use snapshot disk $TMPDISK"

# Build up the virt-install command
cmd='virt-install --import'
cmd+=" --name $NAME"
cmd+=" --filesystem=/var/b/shared/,var-b-shared,driver.type=virtiofs --memorybacking=source.type=memfd,access.mode=shared"
cmd+=" --cpu  host-passthrough" # for nested virt (x86_64 only)
#cmd+=" --arch aarch64"
cmd+=" --ram  $RAMSIZE"
cmd+=" --vcpus $VCPUS"
cmd+=" --disk backing_store=${DISK},size=${DISKSIZE},bus=scsi,discard=unmap"
cmd+=" --disk size=10,bus=scsi,discard=unmap" # A 2nd disk for whatever
#cmd+=" --disk size=10,bus=scsi,discard=unmap" # A 2nd disk for whatever
#cmd+=" --disk path=$TMPISO"
cmd+=" --accelerate"
#cmd+=" --graphics none"
cmd+=" --autoconsole text"
cmd+=" --network bridge=$BRIDGE,model=virtio"
#cmd+=" --network bridge=$BRIDGE,model=virtio"
#cmd+=" --network bridge=virbr1,model=virtio,mac=00:16:3e:77:e2:e4"
#cmd+=" --network network=default,model=virtio"
cmd+=" --channel unix,mode=bind,target_type=virtio,name='org.qemu.guest_agent.0'"
cmd+=" --controller=scsi,model=virtio-scsi"
cmd+=" --os-variant=fedora-unknown"
#cmd+=" --tpm backend.type=emulator,backend.version=2.0,model=tpm-tis"

# for ignition
#cmd+=' --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/guests/sharedfolder/code/github.com/dustymabe/virtscripts/user-systemd.ign"'

#USERDATAFILE=$(mktemp)
#echo "$USERDATA" > $USERDATAFILE
#cmd+=" --cloud-init=user-data=$USERDATAFILE"

#cmd+=" --cloud-init=ssh-key=/var/annex/sync/ssh_keys/HOME/home21_ecdsa.pub"

#cmd+=" --boot uefi"
cmd+=" --boot menu=on,useserial=on"
#cmd+=" --boot menu=on"

# Run the command
echo "Running: $cmd"
set -x

$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/grub-passwd.ign"
#$cmd
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/tmp/kvc/config.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/tmp/config.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/code/github.com/ashcrow/filetranspiler/links.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/code/github.com/dustymabe/virtscripts/user-systemd.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/code/github.com/dustymabe/virtscripts/mounts.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/code/github.com/dustymabe/virtscripts/example.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcct-auto-login-ttyS0.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcct_rollout_wariness.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcct_download_file.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/ignition-with-auto-login.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/entitlements.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/code/gitlab.com/dustymabe/weechat/weechat.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/assembler/teaming.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/assembler/simple.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/assembler/demo/teaming.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/assembler/awsfcos.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/config.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/code/gitlab.com/dustymabe/pc-ansible-config/provisioning/pibackup/pibackup.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/luks.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/rpm-layering.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/boot-mirror.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/path-unit-issue.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/kargs.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/enable-oomd.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/pi.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/rhcos.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcct_more_users.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/issue-512.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcct_silence_audit.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcct_append_etc_issue.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcct_zram_generator.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcct_enable_dnsmasq.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcct-var-log.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/ignition-issue-1041.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcct_enable_linger_core.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcct_iptables_nft.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/ask-fedora-13126.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/code/pagure.io/releng/archive-repo-manager/bug.ign.json"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/shared/code/gitlab.com/dustymabe/notes/code/github.com/dustymabe/dustymabe.com/notes/dustymabecom.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/fcos_verbose_network_manager.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/podman-docker-socket.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/var-mirror.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/auto-login-serial-console-ttyS0.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/user-timers.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/users.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/root-ssh-login.ign"
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/swaponzram.ign"

#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=/var/b/images/tutorials.ign"

# Doesn't work
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,string='$(cat /var/b/shared/assembler/teaming.ign)'"

#ignitionfile=$(mktemp)
#echo "$USERDATA" > $ignitionfile 
#$cmd --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${ignitionfile}"
