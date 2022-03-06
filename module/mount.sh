#!/bin/bash
sudo mkdir -p /var/lib/postgresql
sleep 2s
sudo parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%
sleep 2s
sudo mkfs.xfs /dev/sdc1
sleep 2s
sudo partprobe /dev/sdc1
sleep 2s
sudo mount /dev/sdc1 /var/lib/postgresql
sleep 2s
sudo bash -c 'echo "/dev/sdc1 /var/lib/postgresql    xfs   defaults,nofail   1   2" >> /etc/fstab'
wget  https://aka.ms/downloadazcopy-v10-linux
tar -xvf downloadazcopy-v10-linux
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

