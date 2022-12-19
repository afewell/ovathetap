#!/bin/bash

## This script can be called with an input variable ${1} of "-u" for unattended installation

## Script variables
### Inject envars from input file
source "./scripts/inputs/vars-1.env.sh"
### Inject Secret variables from input file 
source "./scripts/inputs/secrets.env.sh"

## Import Functions
source "./scripts/modules/functions.sh"

# Main

# Setup passwordless sudo
sudo echo "sed '/root/a ${hostusername} ALL=(ALL:ALL) ALL'" | tee -a /etc/sudoers
# The following line check to see if this script was called with the -u flag, which sets the {install_all} variable to y, which provides an unattended/noninteractive execution
if [ "${1}" = "-u" ]; then install_all=y; fi

if [ "${install_all}"  ]; then install=y; else read -p  "Refresh snap to prevent Ubuntu error? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    killall snap-store
    snap refresh
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install ntp? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "ntp"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install curl? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "curl"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install vim? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "vim"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install git? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "git"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install age? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "age-v1_0_0.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install Docker CE? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "dockerce.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install VS Code? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "vscode.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install JQ? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "jq"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install minikube? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "minikube.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install kubectl? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "kubectl.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install helm? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "helm.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install dnsmasq? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "dnsmasq.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Setup private certificate authority? (y/n):" install; fi
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
