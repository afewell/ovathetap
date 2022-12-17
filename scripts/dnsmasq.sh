#!/bin/bash
## abstract the hosts currently configured dns servers
eth_int_name="ens160"
init_dns_addresses=$(nmcli device show ${eth_int_name} | grep IP4.DNS | awk '{print $2}')
init_primary_dns=$(echo ${init_dns_addresses} | head -n 1)
dns_resolv_content=$(echo ${init_dns_addresses} | sed 's/^/nameserver /;1i nameserver 127.0.0.1')
## Disable systemd-resolved
systemctl disable systemd-resolved
systemctl stop systemd-resolved
unlink /etc/resolv.conf
## create temporary resolv.conf
echo "nameserver ${init_primary_dns}" | tee /etc/resolv.conf
apt update
apt install dnsmasq -y
## Disable NetworkManager DNS Resolution
cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.old
sed -i '/plugins/a dns=none' /etc/NetworkManager/NetworkManager.conf
## Update resolv.conf to use dnsmasq for local resolution
mv /etc/resolv.conf /etc/resolv.old
echo ${dns_resolv_content} | tee /etc/resolv.conf