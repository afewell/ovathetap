#!/bin/bash

## Copy, uncomment and enter the following commands to execute this script 
# wget -O /tmp/taphostprep-3.sh https://raw.githubusercontent.com/afewell/ovathetap/main/scripts/compound/taphostprep-3.sh
# sudo chmod +x /tmp/taphostprep-3.sh 
# sudo /tmp/taphostprep-3.sh

## Note: if any manual steps will be required after any install script, you can append instructions to >> /tmp/postactions.txt from the install script, and these will be displayed to the user at the end of this script  

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

## Install Tanzu CLI
cd "/${home_dir}/Downloads" || return
# create a directory to unzip the tanzu CLI files to
mkdir "/${home_dir}/tanzu"
# unzip the file and install Tanzu CLI
tar -xvf "${tanzu_cli_bundle_filename}" -C "/${home_dir}/tanzu"
export TANZU_CLI_NO_INIT=true
cd "/${home_dir}/tanzu" || return
export VERSION=${tanzu_cli_version}
sudo install "cli/core/$VERSION/tanzu-core-linux_amd64" /usr/local/bin/tanzu
tanzu plugin install --local cli all

## Install Cluster Essentials
cd "/${home_dir}/Downloads" || return
# create a directory to unzip the tap installer files to
mkdir "/${home_dir}/tanzu-cluster-essentials" 
# unzip the file and install cluster essentials
tar -xvf "${cluster_essentials_bundle_filename}" -C "/${home_dir}/tanzu-cluster-essentials"
kubectl create namespace kapp-controller
kubectl create secret generic kapp-controller-config \
   --namespace kapp-controller \
   --from-file caCerts=/home/viadmin/.pki/myca/myca.pem
export INSTALL_BUNDLE="${cluster_essentials_bundle_url}"
export INSTALL_REGISTRY_HOSTNAME="${tanzunet_hostname}"
export INSTALL_REGISTRY_USERNAME="${tanzunet_username}"
export INSTALL_REGISTRY_PASSWORD="${tanzunet_password}"
cd "/${home_dir}/tanzu-cluster-essentials" || return
./install.sh --yes
# add carvel apps to path
sudo cp $HOME/tanzu-cluster-essentials/kapp /usr/local/bin/kapp
sudo cp $HOME/tanzu-cluster-essentials/imgpkg /usr/local/bin/imgpkg
sudo cp $HOME/tanzu-cluster-essentials/kbld /usr/local/bin/kbld
sudo cp $HOME/tanzu-cluster-essentials/ytt /usr/local/bin/ytt

