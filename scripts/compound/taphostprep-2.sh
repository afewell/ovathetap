#!/bin/bash

## Copy, uncomment and enter the following commands to execute this script 
### wget -O /tmp/taphostprep-1.sh https://raw.githubusercontent.com/afewell/ovathetap/main/scripts/compound/taphostprep-2.sh
### sudo chmod +x /tmp/taphostprep-2.sh 
### sudo /tmp/taphostprep-2.sh

## Note: if any manual steps will be required after any install script, you can append instructions to >> /tmp/postactions.txt from the install script, and these will be displayed to the user at the end of this script  

## Import Functions
### There are currently no function calls in this script, so this section is commented out
# export raw_git_url="https://raw.githubusercontent.com/afewell/ovathetap/main"
# export functions_path="scripts"
# export functions_filename="functions.sh"
# export script_tmp_dir="/tmp/taphostprep-2/"
# mkdir /tmp/taphostprep-2
# wget "${raw_git_url}/${functions_path}/${functions_filename}" -O "/tmp/taphostprep-1/${functions_filename}"
# source "${script_tmp_dir}${functions_filename}"
# rm "${script_tmp_dir}${functions_filename}"

## Global variables
### Inject envars from input file
#### There are currently no required input vars in this script, so this section is commented
# export inputs_path="scripts/inputs"
# export envars_filename="vars-2.env.sh"
# #### Call func_github_file_download function to have it save the input envars file to the script temporary directory
# func_github_file_download "${inputs_path}/${envars_filename}" "${script_tmp_dir}"

### Inject Secret variables from input file 
### There are no secrets to inject in this script so section is commented out for reference
# export secrets_filename_encrypted="secrets-2.env.sh.age"
# ### Gather secrets file decryption passphrase 
# read -p "Enter the decryption passphrase for the secrets-2.env.sh.age file" secret_decryption_passphrase
# ### TODO add lines here to decrypt secrets-2.env.sh.age file and save decrypted file in the variable secrets_filename as ${script_tmp_dir}secrets-1.env.sh
# source "${script_tmp_dir}${secrets_filename}"
# rm "${script_tmp_dir}${secrets_filename}"

# Main

## Start Minikube
minikube start --kubernetes-version='1.23.10' --memory='48g' --cpus='12' --embed-certs --insecure-registry=192.168.49.0/24
### Gather minikube IP
echo "the minikube ip is: $(minikube ip)"
export minikubeip=$(minikube ip)
### Configure dnsmasq to resolve every request to *.tanzu.demo to the minikube IP
mv /etc/dnsmasq.conf /etc/dnsmasq.old
echo "address=/tanzu.demo/${minikubeip}" | tee /etc/dnsmasq.conf
systemctl restart dnsmasq

