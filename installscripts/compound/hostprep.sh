#!/bin/bash

## Copy, uncomment and enter the following commands to execute this script 
### wget -O /tmp/devhost.sh https://raw.githubusercontent.com/afewell/taphostprep-type1/main/installscripts/compound/devhost.sh
### sudo chmod +x /tmp/devhost.sh 
### sudo /tmp/devhost.sh

## Note: if any manual steps will be required after any install script, you can append instructions to >> /tmp/postactions.txt from the install script, and these will be displayed to the user at the end of this script  

## Global variables
### note that scripts executed by this script cannot gather user inputs
read -p "Enter your exact username for this host - default value is viadmin: " user
user=${user:-viadmin}
echo "user value is: ${user}"

## Define Functions
### There are currently 3 forms of install command sequences used in this script
### 1. func_apt_install updates apt and then executes apt install {installkeyword} -y
### 2. func_install_script downloads an install script from this repo and sources it for execution from this env
### 3. func_clone_repo clones a repo from the users home directory

func_apt_install () {
    echo "##################################################" | tee -a /tmp/taphostprep.log
    echo "# Installing: $1 " | tee -a /tmp/taphostprep.log
    echo "##################################################" | tee -a /tmp/taphostprep.log
    apt-get update | tee -a /tmp/taphostprep.log
    apt install "$1" -y | tee -a /tmp/taphostprep.log
    echo "##################################################" | tee -a /tmp/taphostprep.log
    echo "# Finished Installing: $1 " | tee -a /tmp/taphostprep.log
    echo "##################################################" | tee -a /tmp/taphostprep.log
}

func_install_script () {
    echo "##################################################" | tee -a /tmp/taphostprep.log
    echo "# Installing: $1 " | tee -a /tmp/taphostprep.log
    echo "##################################################" | tee -a /tmp/taphostprep.log
    wget https://raw.githubusercontent.com/afewell/taphostprep-type1/main/installscripts/$1 -O /tmp/$1 | tee -a /tmp/taphostprep.log
    chmod +x "/tmp/$1" | tee -a /tmp/taphostprep.log
    source "/tmp/$1" | tee -a /tmp/taphostprep.log
    rm "/tmp/$1" | tee -a /tmp/taphostprep.log
    echo "##################################################" | tee -a /tmp/taphostprep.log
    echo "# Finished Installing: $1 " | tee -a /tmp/taphostprep.log
    echo "##################################################" | tee -a /tmp/taphostprep.log
}

func_clone_repo () {
    echo "##################################################" | tee -a /tmp/taphostprep.log
    echo "# Cloning Repository: $1 " | tee -a /tmp/taphostprep.log
    echo "##################################################" | tee -a /tmp/taphostprep.log
    cd "/home/${user}" || return  | tee -a /tmp/taphostprep.log
    git clone "$1" | tee -a /tmp/taphostprep.log
    reponame=$(echo ${1##*/}) | tee -a /tmp/taphostprep.log
    chown -R "/home/${user}/${reponame}" | tee -a /tmp/taphostprep.log
    echo "##################################################" | tee -a /tmp/taphostprep.log
    echo "# Finished Cloning Repository: $1 " | tee -a /tmp/taphostprep.log
    echo "##################################################" | tee -a /tmp/taphostprep.log
}

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

read -p "Clone the afewell/taphostprep-type1 repo? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_clone_repo "https://github.com/afewell/taphostprep-type1.git"
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

read -p "Install kubectl 1.23.10? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "kubectl_1-23-10.sh"
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
