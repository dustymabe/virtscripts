#!/usr/bin/python

#TODO add interactive option y/N for each image
#TODO add dry-run option

import os
import sys
import urllib
import hashlib
import subprocess

IMGDIR = '/guests/images/'

IMAGES = {
    # F21 released cloud base x86_64 qcow2
    'https://download.fedoraproject.org/pub/fedora/linux/releases/21/Cloud/Images/x86_64/Fedora-Cloud-Base-20141203-21.x86_64.qcow2' :
        '3a99bb89f33e3d4ee826c8160053cdb8a72c80cd23350b776ce73cd244467d86',
    # F21 released cloud atomic x86_64 qcow2
    'https://download.fedoraproject.org/pub/fedora/linux/releases/21/Cloud/Images/x86_64/Fedora-Cloud-Atomic-20141203-21.x86_64.qcow2' :
        '1232b60af3d826b832645b15b657225b856aae327329db7bf5efb1d2cbc4fe56',

    # F22 released 20150521 cloud base x86_64 qcow2
    'https://download.fedoraproject.org/pub/fedora/linux/releases/22/Cloud/x86_64/Images/Fedora-Cloud-Base-22-20150521.x86_64.qcow2' :
        'a5d6da626667e21f7de04202c8da5396c0fc7e26872d016f3065f1110cff7962',
    # F22 released cloud atomic x86_64 qcow2
    'https://download.fedoraproject.org/pub/fedora/linux/releases/22/Cloud/x86_64/Images/Fedora-Cloud-Atomic-22-20150521.x86_64.qcow2' :
        '9a175fca23ff46823ca9a87ab63d425801b02c2d4f17306c74e00b7280f8117f',

    # F23 server ISO 
  ##'https://download.fedoraproject.org/pub/fedora/linux/releases/23/Server/x86_64/iso/Fedora-Server-DVD-x86_64-23.iso' :
  ##    '30758dc821d1530de427c9e35212bd79b058bd4282e64b7b34ae1a40c87c05ae',
    # F23 released 20151030 cloud base x86_64 qcow2
    'https://download.fedoraproject.org/pub/fedora/linux/releases/23/Cloud/x86_64/Images/Fedora-Cloud-Base-23-20151030.x86_64.qcow2' :
        '0c30ef4f0c2e1bc621193d0ee42b7692e19e93aa286abc6e08683397f35d7b0f',
    # F23 released 20151030 atomic x86_64 qcow2
    'https://download.fedoraproject.org/pub/fedora/linux/releases/23/Cloud/x86_64/Images/Fedora-Cloud-Atomic-23-20151030.x86_64.qcow2' :
        '57d4025915cc83e948d155e44c582fa154df33d801175fcf50d69181505b5433',
    # F23 released 20151201 atomic x86_64 qcow2
    'https://download.fedoraproject.org/pub/alt/atomic/stable/Cloud-Images/x86_64/Images/Fedora-Cloud-Atomic-23-20151201.x86_64.qcow2' :
        '95ccacb4f0c94ffbb6e0d1802f7cbf691f92b4684d39f1ea9d6844b2cb61a568',
    # F23 released 20151201 atomic x86_64 qcow2
    'https://download.fedoraproject.org/pub/alt/atomic/stable/Cloud-Images/x86_64/Images/Fedora-Cloud-Atomic-23-20160308.x86_64.qcow2' :
        '2c6f6f728c94fe49d9a4f0e95b08792657f468a41057ad29a318955ecac99ef1',

    # F24 released cloud base x86_64 qcow2
    'https://download.fedoraproject.org/pub/fedora/linux/releases/24/CloudImages/x86_64/images/Fedora-Cloud-Base-24-1.2.x86_64.qcow2' :
        'eca5113d3611ae5060c85032f5674fa9e1c237ff66cd2f47352a23e6fdfaac38',
    # F24 first released Atomic x86_64 qcow2
    'https://download.fedoraproject.org/pub/alt/atomic/stable/CloudImages/x86_64/images/Fedora-Atomic-24-20160712.0.x86_64.qcow2' :
        'fbd042545d46928ced9578eafc27cc67fb60a62a2087d3d1d38d7b2b23c49b93',

    # F24 released 20160809 atomic x86_64 qcow2
    'https://download.fedoraproject.org/pub/alt/atomic/stable/CloudImages/x86_64/images/Fedora-Atomic-24-20160809.0.x86_64.qcow2' :
        '6935b2d633e1114b5ddd474c62bf748299b7ae5693feb9e920e876b2e1b3bd6a',

    # C7 released 20151001 atomic qcow2
    'http://cloud.centos.org/centos/7/atomic/images/CentOS-Atomic-Host-7.20151001-GenericCloud.qcow2' :
        '55aa4c3a7e0865f54c508ded637b01e6f42b571980a6d54ad04fd4d691f407ca',
    # C7 released 1503 cloud base 
    'http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1503.qcow2' :
        'e324e3ab1d24a1bbf035ddb365e7f9058c0b454acf48d7aa15c5519fae5998ab',
    # C7 released 1509 cloud base 
    'http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1509.qcow2' :
        '1ed60e89401fcd4fe1b7387452ff41afd617c30e10dd5623438a0231b5694be9',
    # C7 released 1511 cloud base 
    'http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1511.qcow2' :
        '0ef6f432a0b032b2dfac958e4fb0fcabce456af35807993d00cc82f30d60df8e',

    # RHEL 7.2 (beta)
    'nourl/rhel-guest-image-7.2-20150821.0.x86_64.qcow2' :
        '2a30f30448b671b88a7938ecbff52008fde54eee8e96d295e034d244625367ed',
    # RHEL 7.2-20160219.1
    'nourl/rhel-guest-image-7.2-20160219.1.x86_64.qcow2' :
        '5a55b49923ff80016c0221fe27caf4ff274b863a5df9fc148fb0af3c3a49df79',

    # RHEL Atomic Host  7.2.3-1
    'nourl/rhel-atomic-cloud-7.2-13.x86_64.qcow2' :
        'fb1a6c304a136425592b2ff0c5c2b2386dbf7086a77a7e622f5881e4cd73ca81',

    # RHEL CDK 7.2-23
    'nourl/rhel-cdk-kubernetes-7.2-23.x86_64.vagrant-libvirt.box' :
        '70342fe0e3d40265a791e5c61dd6ddba8ce368b5b1f4fa8daf3939e8c585f1f4',
}

def main():
    interactive = True
    for url, sum in IMAGES.iteritems():
        # Determine path where the file will reside
        filepath = os.path.join(IMGDIR, os.path.basename(url))
        print(os.path.basename(url))

        # if image doesn't exist then download it
        if not os.path.exists(filepath):
            if interactive:
                answer = ''
                while answer.lower() != 'y' and answer.lower() != 'n':
                    print("\tFile %s does not exist... Download now? (y/N)" % filepath)
                    answer = sys.stdin.read(1)
                if answer.lower() == 'y':
                    print("\tDownloading...")
                    urllib.urlretrieve(url, filepath)
                else:
                    next
            else:
                print("\tFile %s does not exist... Downloading..." % filepath)
                urllib.urlretrieve(url, filepath)


        # Check the checksum if the user specified one
        if sum != 'none' and os.path.exists(filepath):

            # Figure out the checksum
            filesum = hashlib.sha256()
            with open(filepath) as fp:
                filesum.update(fp.read())

            print("\t    sum: " + sum)
            print("\tfilesum: " + filesum.hexdigest())

            if sum == filesum.hexdigest():
                print("\t\tTHEY MATCH")
              ##print("\t\tMAKING IT IMMUTABLE")
              ##cmd = "/usr/bin/chattr +i {}".format(filepath)
              ##subprocess.check_call(cmd.split())
            else:
                raise BaseException("they do not match")
    return

if __name__ == "__main__":
    main()
