#!/usr/bin/python

import os
import sys
import urllib
import hashlib

IMGDIR = '/guests/images/'

IMAGES = {
    # F21 released cloud base x86_64 qcow2
    'https://download.fedoraproject.org/pub/fedora/linux/releases/21/Cloud/Images/x86_64/Fedora-Cloud-Base-20141203-21.x86_64.qcow2' :
        '3a99bb89f33e3d4ee826c8160053cdb8a72c80cd23350b776ce73cd244467d86',
#   # F21 released cloud atomic x86_64 qcow2
#   'https://download.fedoraproject.org/pub/fedora/linux/releases/21/Cloud/Images/x86_64/Fedora-Cloud-Atomic-20141203-21.x86_64.qcow2' :
#       '1232b60af3d826b832645b15b657225b856aae327329db7bf5efb1d2cbc4fe56',
    # F22 released 20150521 cloud base x86_64 qcow2
    'https://download.fedoraproject.org/pub/fedora/linux/releases/22/Cloud/x86_64/Images/Fedora-Cloud-Base-22-20150521.x86_64.qcow2' :
        'a5d6da626667e21f7de04202c8da5396c0fc7e26872d016f3065f1110cff7962',
    # F22 released cloud atomic x86_64 qcow2
    'https://download.fedoraproject.org/pub/fedora/linux/releases/22/Cloud/x86_64/Images/Fedora-Cloud-Atomic-22-20150521.x86_64.qcow2' :
        '9a175fca23ff46823ca9a87ab63d425801b02c2d4f17306c74e00b7280f8117f',
    # C7 released 20151001 atomic qcow2
    'http://cloud.centos.org/centos/7/atomic/images/CentOS-Atomic-Host-7.20151001-GenericCloud.qcow2' :
        '55aa4c3a7e0865f54c508ded637b01e6f42b571980a6d54ad04fd4d691f407ca',
    # C7 released 1503 cloud base 
    'http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1503.qcow2' :
        'e324e3ab1d24a1bbf035ddb365e7f9058c0b454acf48d7aa15c5519fae5998ab',
    # C7 released 1509 cloud base 
    'http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1509.qcow2' :
        '1ed60e89401fcd4fe1b7387452ff41afd617c30e10dd5623438a0231b5694be9',
    # F23 beta 
    'https://download.fedoraproject.org/pub/fedora/linux/releases/test/23_Beta/Cloud/x86_64/Images/Fedora-Cloud-Base-23_Beta-20150915.x86_64.qcow2' :
        '50ccbed2d5ae89b86c19ae930f676b060c2dbab1806029dd55357ae5952521c3',
    # F23 server ISO 
    'http://dl.fedoraproject.org/pub/alt/stage/23_TC11/Server/x86_64/iso/Fedora-Server-DVD-x86_64-23_TC11.iso' :
        '903812b5fa20a00c8ba77a942ca0799654dd3acc698b78e586bf4c3fbe12b0fe',
}

def main():
    for url, sum in IMAGES.iteritems():
        # Determine path where the file will reside
        filepath = os.path.join(IMGDIR, os.path.basename(url))
        print(os.path.basename(url))

        # if image doesn't exist then download it
        if not os.path.exists(filepath):
            print("\tFile %s does not exist... Downloading..." % filepath)
            urllib.urlretrieve(url, filepath)


        # Check the checksum if the user specified one
        if sum != 'none':

            # Figure out the checksum
            filesum = hashlib.sha256()
            with open(filepath) as fp:
                filesum.update(fp.read())

            print("\t    sum: " + sum)
            print("\tfilesum: " + filesum.hexdigest())

            if sum == filesum.hexdigest():
                print("\t\tTHEY MATCH")
                continue
            else:
                raise BaseException("they do not match")
    return

if __name__ == "__main__":
    main()
