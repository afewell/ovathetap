#!/bin/bash
# Liberica JDK 17 Install Script
## Add BellSoft official GPG key
wget -qO - https://download.bell-sw.com/pki/GPG-KEY-bellsoft | sudo apt-key add -
## Add BellSoft repository
echo "deb https://apt.bell-sw.com/ stable main" | sudo tee /etc/apt/sources.list.d/bellsoft.list
## Update package list
sudo apt-get update
## Install Liberica JDK 17
sudo apt-get install bellsoft-java17