#!/bin/bash
## Disable systemd-resolved
systemctl disable systemd-resolved
systemctl stop systemd-resolved
unlink /etc/resolv.conf
## create temporary resolv.conf
echo nameserver 8.8.8.8 | tee /etc/resolv.conf
apt update
apt install dnsmasq -y
## Disable NetworkManager DNS Resolution
wget -O /tmp/NetworkManager.conf https://raw.githubusercontent.com/afewell/taphostprep-type1/main/assets/NetworkManager.conf
chown "root:" /tmp/NetworkManager.conf
chmod 644 /tmp/NetworkManager.conf
mv /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.old
cp /tmp/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
## Update resolv.conf to use dnsmasq for local resolution
echo "nameserver 127.0.0.1" | tee /etc/resolv.conf
echo "nameserver 8.8.8.8" | tee -a /etc/resolv.conf
echo "nameserver 8.8.4.4" | tee -a /etc/resolv.conf