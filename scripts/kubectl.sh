#!/bin/bash
kubernetes_version="${kubernetes_version}
"
cd /tmp
curl -LO "https://dl.k8s.io/release/v${kubernetes_version}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
cd /home/$user
