#!/bin/bash
## Install steps from https://docs.docker.com/engine/install/ubuntu/
## Install Prerequisites
hostusername=${hostusername}
apt-get update
apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

## Add Docker’s official GPG key:

mkdir -p /etc/apt/keyrings
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

 ## set up the repository:

 echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

## Install Docker CE

 apt-get update 
 apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y


## User will need to manually enter command after script completes:
## Post install steps and sudoless for user https://docs.docker.com/engine/install/linux-postinstall/
echo "##################################################" | tee -a /tmp/postactions.txt
echo '# You will need to manually enter the following commands after this script completes:' | tee -a /tmp/postactions.txt
echo "# groupadd docker -f" | tee -a /tmp/postactions.txt
echo "# usermod -aG docker ${hostusername}" | tee -a /tmp/postactions.txt
echo "# newgrp docker" | tee -a /tmp/postactions.txt
echo "# after entering the above commands, reboot the host" | tee -a /tmp/postactions.txt
echo "##################################################" | tee -a /tmp/postactions.txt

systemctl enable docker.service
systemctl enable containerd.service