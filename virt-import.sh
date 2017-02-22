#!/bin/bash

# exit on any error
set -o errexit

# A few tunable variables
NAME='tester'
#DISK='/guests/images/Fedora-Cloud-Base-23-20151008.x86_64.qcow2'
#DISK='/guests/images/Fedora-Cloud-Base-23_Beta_TC4-20150907.x86_64.qcow2'
#DISK='/guests/images/Fedora-Cloud-Atomic-23-20151013.x86_64.qcow2'
#DISK='/guests/images/CentOS-Atomic-Host-7.20151001-GenericCloud.qcow2'
#DISK='/guests/images/Fedora-Cloud-Atomic-rawhide-20151013.x86_64.qcow2'
#DISK='/guests/images/CentOS-7-x86_64-GenericCloud-1509.qcow2'
#DISK='/guests/images/Fedora-Cloud-Atomic-20141203-21.x86_64.qcow2' # Official F21 Atomic Release
#DISK='/guests/images/Fedora-Cloud-Base-20141203-21.x86_64.qcow2'   # Official F21 Cloud Base Release
#DISK='/guests/images/Fedora-Cloud-Atomic-22-20150521.x86_64.qcow2' # Official F22 Atomic Release
#DISK='/guests/images/Fedora-Cloud-Base-22-20150521.x86_64.qcow2'   # Official F22 Cloud Base Release
#DISK='/guests/images/Fedora-Cloud-Atomic-23-20151030.x86_64.qcow2' # Official F23 Atomic Release 
#DISK='/guests/images/Fedora-Cloud-Base-23-20151030.x86_64.qcow2'   # Official F23 Cloud Base Release
#DISK='/guests/images/Fedora-Cloud-Atomic-23-20151201.x86_64.qcow2' # Official F23 - 2 Week Atomic 20151201
#DISK='/guests/images/Fedora-Cloud-Atomic-23-20160308.x86_64.qcow2' # Official F23 - 2 Week Atomic 20160308
#DISK='/guests/images/Fedora-Cloud-Base-24-1.2.x86_64.qcow2'        # Official F24 - Cloud Base Release Day Release
#DISK='/guests/images/Fedora-Atomic-24-20160712.0.x86_64.qcow2'     # Official F24 - Atomic 24 First Release
#DISK='/guests/images/Fedora-Atomic-24-20160809.0.x86_64.qcow2'     # Official F24 - 2 Week Atomic 20160809
#DISK='/guests/images/Fedora-Cloud-Base-25-1.3.x86_64.qcow2'        # Official F25 - Cloud Base Release Day Release

#DISK='/guests/images/CentOS-7-x86_64-GenericCloud-1511.qcow2'      # Official C7 - 1511
#DISK='/guests/images/rhel-guest-image-7.2-20150821.0.x86_64.qcow2' # RHEL 7.2 beta
#DISK='/guests/images/rhel-guest-image-7.2-20160219.1.x86_64.qcow2' # RHEL 7.2-20160219.1

DISK='/guests/images/Fedora-Atomic-25-20170131.0.x86_64.qcow2'
DISK='/guests/images/cloud-init-atomic-updates-testing.img'
DISK='/guests/images/Fedora-Cloud-Base-25-20170206.0.x86_64.qcow2'
DISK='/guests/images/Fedora-Atomic-25-20170206.0.x86_64.qcow2'
DISK='/guests/images/Fedora-Atomic-25-20170209.2.x86_64.qcow2'
DISK='/guests/images/image-newer-NM-new-cloud-init.qcow2'


ISATOMIC=0
RAMSIZE='4096' # IN MB
DISKSIZE='20'  # IN GB
VCPUS='2'      # NUM of CPUs
BRIDGE='virbr0'
TMPISO="/guests/storagepools/manual/user-data-iso.iso${RANDOM}"
TMPDISK="/guests/storagepools/manual/$(basename ${DISK})${RANDOM}"

USERDATA='
#cloud-config
password: passw0rd
chpasswd: { expire: False }
ssh_pwauth: True

### Section to install qemu-guest-agent and start the service
#   packages:
#     - qemu-guest-agent
#   runcmd:
#     - [ systemctl, start, --no-block, qemu-guest-agent.service ]

### Section to set up storage for docker
bootcmd:
# For devicemapper  
#- echo 'DEVS=/dev/sdb' >>  /etc/sysconfig/docker-storage-setup
#- echo 'VG=vgdocker' >>  /etc/sysconfig/docker-storage-setup
# For overlay
- echo 'ROOT_SIZE=9G' >>  /etc/sysconfig/docker-storage-setup
- echo 'STORAGE_DRIVER=overlay2' >>  /etc/sysconfig/docker-storage-setup
#
#- echo 'DATA_SIZE=100%FREE' >>  /etc/sysconfig/docker-storage-setup


#disable_root: False

### Section to create an "atomic" user with ssh key
#   users:
#     - default
#     - name: atomic
#       gecos: Atomic User
#       sudo: ["ALL=(ALL) NOPASSWD:ALL"]
#       groups: [wheel, adm, systemd-journal]
#       ssh-authorized-keys:
#           - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOLFvRYlf2UTC7lZjWO70hKGqtq6Bu+DruqJsXHE/E+v9ziTWebuEcSOZmGNRTNm7CqDoqTJgH5uPrqHfokA+kmMojefqJ9Ha9KY5l8ea9Hk88S9P4ryAW01zFkRY55xBwyIzKL9wReEFvCYTTIHOiRZbDq8PstrPwh8sXBOJhdHzLvjbuDAz7fdgH7/JBsf/FPKJ61aQkjs2a9Xfx5yC9J8wbbvLHU9myxfKPgxMLbWEnAEbFJfUGY849ZO4AiFZHYnQgQaMS1WFpEXBsA8VsFI6pzGAxCs0+7Eyy5fvUTznXdaTpr+vmMxCBllm3M3qGDVZCH04oiEKKUC+2BVQr

#growpart:
#  mode: off
'
if [ "$ISATOMIC" == "1" ]; then
    USERDATA+="
write_files:
-   owner: root:root
    path: /etc/systemd/system/cockpitws.service
    permissions: '0644'
    content: |
[Unit]
Description=Cockpit Web Interface
Requires=docker.service
After=docker.service
[Service]
Restart=on-failure
RestartSec=10
ExecStart=/usr/bin/docker run --rm --privileged --pid host -v /:/host --name %p fedora/cockpitws /container/atomic-run --local-ssh
ExecStop=-/usr/bin/docker stop -t 2 %p
[Install]
WantedBy=multi-user.target

runcmd:
- echo 'nameserver 192.168.1.1' > /etc/resolv.conf
- [ systemctl, daemon-reload ]
- [ systemctl, enable, cockpitws.service ]
- [ systemctl, start, --no-block, cockpitws.service ]
#- [ systemctl, start, docker-storage-setup.service ]
#- [ systemctl, start, docker.service ]

"
fi
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


echo "Creating user data iso $TMPISO"
pushd $(mktemp -d)
mkdir -p openstack/latest/
echo "$NETWORKDATA" > openstack/latest/network_data.json
echo "$USERDATA" > user-data
echo "$METADATA" > meta-data
genisoimage -output $TMPISO -volid cidata -joliet -rock user-data meta-data openstack/latest/network_data.json
popd

echo "Creating snapshot disk $TMPDISK"
qemu-img create -f qcow2 -b $DISK $TMPDISK ${DISKSIZE}g
echo "Will use backing disk $DISK"
echo "Will use snapshot disk $TMPDISK"

# Build up the virt-install command
cmd='virt-install --import'
cmd+=" --name $NAME"
cmd+=" --cpu  host-passthrough" # for nested virt
cmd+=" --ram  $RAMSIZE"
cmd+=" --vcpus $VCPUS"
#cmd+=" --disk path=$TMPDISK,size=10,backing_store=${DISK}"
cmd+=" --disk path=$TMPDISK"
cmd+=" --disk path=${TMPDISK}.2,size=10" # A 2nd disk for whatever
#cmd+=" --disk path=$DISK"
cmd+=" --disk path=$TMPISO"
cmd+=" --accelerate"
cmd+=" --graphics none"
cmd+=" --force"
cmd+=" --network bridge=$BRIDGE,model=virtio"
cmd+=" --channel unix,mode=bind,target_type=virtio,name='org.qemu.guest_agent.0'"

# Run the command
echo "Running: $cmd"
$cmd
