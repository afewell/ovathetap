#!/bin/bash

cd /tmp
curl -LO https://dl.k8s.io/release/v1.23.10/bin/linux/amd64/kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
cd /home/$user
