#!/bin/bash

## Script variables
### Inject envars from input file
source "./scripts/inputs/vars-1.env.sh"
### Inject Secret variables from input file 
source "./scripts/inputs/secrets.env.sh"

## Import Functions
source "./scripts/modules/functions.sh"

# Main

read -p "Refresh snap to prevent Ubuntu error? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    killall snap-store
    snap refresh
fi

read -p "Install ntp? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "ntp"
fi

read -p "Install curl? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "curl"
fi

read -p "Install vim? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "vim"
fi

read -p "Install git? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "git"
fi

read -p "Install age? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "age-v1_0_0.sh"
fi

read -p "Install Docker CE? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "dockerce.sh"
fi

read -p "Install VS Code? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "vscode.sh"
fi

read -p "Install JQ? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "jq"
fi

read -p "Install minikube? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "minikube.sh"
fi

read -p "Install kubectl? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "kubectl.sh"
fi

read -p "Install helm? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "helm.sh"
fi

read -p "Install dnsmasq? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "dnsmasq.sh"
fi

read -p "Setup private certificate authority? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "certificateauthority.sh"
fi



## The below command should be the last thing that executes

if [ -f /tmp/postactions.txt ]
then
    cat /tmp/postactions.txt
    rm /tmp/postactions.txt
fi
