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

## Relocate TAP Images to your install registry
export INSTALL_REGISTRY_USERNAME=admin
export INSTALL_REGISTRY_PASSWORD=Harbor12345
export INSTALL_REGISTRY_HOSTNAME=192.168.49.2:31642
export TAP_VERSION="${tap_version}"
export INSTALL_REPO="${tap_install_repo}"
docker login $INSTALL_REGISTRY_HOSTNAME -u $INSTALL_REGISTRY_USERNAME -p $INSTALL_REGISTRY_PASSWORD
docker login "${tanzunet_hostname}" -u "${tanzunet_username}" -p "${tanzunet_password}"
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages