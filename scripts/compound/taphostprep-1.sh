#!/bin/bash

## Copy, uncomment and enter the following commands to execute this script 
### wget -O /tmp/taphostprep-1.sh https://raw.githubusercontent.com/afewell/ovathetap/main/scripts/compound/taphostprep-1.sh
### sudo chmod +x /tmp/taphostprep-1.sh 
### sudo /tmp/taphostprep-1.sh

## TODO - this statement is outdated Note: if any manual steps will be required after any install script, you can append instructions to >> /tmp/postactions.txt from the install script, and these will be displayed to the user at the end of this script  

## Import Functions
export raw_git_url="https://raw.githubusercontent.com/afewell/ovathetap/main"
export modules_path="scripts/modules"
export functions_filename="functions.sh"
export script_tmp_dir="tmp/taphostprep"
mkdir "/${script_tmp_dir}"
wget "${raw_git_url}/${modules_path}/${functions_filename}" -O "/${script_tmp_dir}/${functions_filename}"
source "/${script_tmp_dir}/${functions_filename}"
rm "/${script_tmp_dir}/${functions_filename}"

## Global variables
### Inject envars from input file
export inputs_path="scripts/inputs"
export envars_filename="vars-1.env.sh"
#### Call func_github_file_download function to have it save the input envars file to the script temporary directory
func_github_file_download "${inputs_path}/${envars_filename}" "${script_tmp_dir}"
source "/${script_tmp_dir}/${envars_filename}"

### Inject Secret variables from input file 
### There are no secrets to inject in this script so section is commented out for reference
# export secrets_filename_encrypted="secrets-1.env.sh.age"
### Gather secrets file decryption passphrase 
# read -p "Enter the decryption passphrase for the secrets-1.env.sh.age file" secret_decryption_passphrase
### TODO add lines here to decrypt secrets-1.env.sh.age file and save decrypted file in the variable secrets_filename as ${script_tmp_dir}secrets-1.env.sh
# source "${script_tmp_dir}${secrets_filename}"
# rm "${script_tmp_dir}${secrets_filename}"

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

read -p "Clone the afewell/ovathetap repo? (y/n):" install
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_clone_repo "https://github.com/afewell/ovathetap.git"
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
