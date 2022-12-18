#!/bin/bash

## Copy, uncomment and enter the following commands to execute this script 
# wget -O /tmp/taphostprep-2.sh https://raw.githubusercontent.com/afewell/ovathetap/main/scripts/compound/taphostprep-2.sh
# sudo chmod +x /tmp/taphostprep-2.sh 
# sudo /tmp/taphostprep-2.sh

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

## Start Minikube
minikube start --kubernetes-version="${kubernetes_version}" --memory="${minikube_memory}" --cpus="${minikube_cpus}" --embed-certs --insecure-registry=192.168.49.0/24
# the following line pauses script execution for 5 seconds to ensure minikube is fully loaded, it may not be necessary and if it is, its probably better in the future to use a different method to dynamically verify minikube readiness before proceeding
read -t 5 -p "minikube cluster deployed, pausing script for 5 seconds"
### Gather minikube IP
echo "the minikube ip is: $(minikube ip)"
export minikubeip=$(minikube ip)
## Configure dnsmasq to resolve every request to *.tanzu.demo to the minikube IP
mv /etc/dnsmasq.conf /etc/dnsmasq.old
echo "address=/tanzu.demo/${minikubeip}" | tee /etc/dnsmasq.conf
systemctl restart dnsmasq
echo "dnsmasq configuration complete"
## Install Harbor
# Login to docker to assist with docker hub rate limiting
docker login -u "${docker_account_username}" -p "${docker_account_password}"
# Gather the harbors.yml file
func_github_file_download "assets/harborvalues.yaml" "/home/${hostusername}/"
# Add the harbor repo to helm
helm repo add harbor https://helm.goharbor.io
# create namespace for harbor
kubectl create ns harbor
# install harbor
helm install harbor harbor/harbor -f /home/${hostusername}/harborvalues.yaml -n harbor
chown ${hostusername}:${hostusername} "/home/${hostusername}/harborvalues.yaml"
read -t 5 -p "completing harbor deployment"
echo "Harbor desired state configuration applied - follow instructions to verify deployment"