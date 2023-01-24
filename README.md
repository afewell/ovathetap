# This lab is under active development and the instructions probably will not work right now as I still have a lot of changes that I need to make which are in-progress
# OvaTheTap
The purpose of this document is to create a complete Full Profile installation for Tanzu Application Platform on a single VM.

The project is currently focused on a single environment topology, using a single, minimal ubuntu desktop VM to install kubernetes and TAP on a single host. The instructions and assets provided here should work on an ubuntu host with sufficient resources and performance, regardless of whether it is on bare metal or any virtualization platform, but the user may need to adjust some values for different environments.

This repository provides instructions and may include content with dependencies on licensed software. This repository does not provide any licensing or access to any licensed products that are referenced within. Should anyone attempt to use any information or content within this repository, it is that users responsibility to comply with all licensing requirements.

The contents of this repository are intended for educational purposes only. Any software configuration references provided are intended for non-production environments and should not be used in any production environment or depended upon in any way. The configuration referenced within is explicitly not supported, and any contributor to this repository does not provide any assurance that any design, configuration or other information/content within should work or function properly in any way. 

# TAP 1.4 Single-node Lab Install Flow

## References:
- [1] https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4
- [2] https://tanzu.vmware.com/developer/guides/cert-manager-gs/
- [3] https://tanzu.vmware.com/developer/guides/tanzu-application-platform-local-devloper-install/
- [4] https://tanzu.vmware.com/developer/guides/harbor-gs/#set-up-dns
- [5] https://github.com/afewell/scripts/
- [6] https://tanzu.vmware.com/developer/blog/securely-connect-with-your-local-kubernetes-environment/
- [7] https://thesecmaster.com/how-to-set-up-a-certificate-authority-on-ubuntu-using-openssl/
- [8] https://computingforgeeks.com/install-and-configure-dnsmasq-on-ubuntu/
- [9] https://goharbor.io/docs/2.6.0/install-config/configure-https/

## Host Preparation and Setup
### Provision an Ubuntu host

- In my initial tests I am using vCloud director to provision a VM (Running on vCenter) with the following specs:
  - CPU's: 16 single core CPU's
  - Memory: 64GB
  - Storage: 200GB HDD
  - OS: Ubuntu 20.04 Desktop (Minimal)
- After provisioning the host I just went through the standard installation wizard with standard/minimum options defined
- At this point I save a copy/template in my virtualization manager so when I need to provision a new VM I can load one up without needing to redo basic installation or maintain some other script to automate it
- **The demo environment uses the default username `viadmin`**. Note that if you want to use a different username in your ubuntu host, please follow the instructions wherever prompted to ensure your preferred linux host username is used. 


- If you are using vCloud director and want to configure the same as the test environment:
  - Create a vApp network named vapp-net
  - Connect vapp-net to an external network
  - Enable firewall service and set default rule to permit any any
  - Enable NAT service with the following settings:
    - port forwarding
    - ip masquerade
    - create rule permitting any to any port forwarding to taphost
  - Create a vApp with a single VM named `taphost` with the specs listed above, plus the following nic configuration:
    - Network Adapter Type: VMXNET3
    - Network: vapp-net
    - IP Mode: Static - Manual
    - IP Address: 192.168.0.2

### Setup IP Address on Ubuntu Host

- Note: The need for this step may depend on your environment, you can use your preferred method to set an IP address, but be aware that if your host IP address changes, it may cause problems in the environment so its best if you use a method that ensures your VM/host gets the same IP address for its lifespan
- Manually set an IP address on your VM so that the VM has internet access. This address does not necessarily need to be reachable from your desktop, but you will need some method to access the UI of the VM. 
- `sudo nano /etc/netplan/01-network-manager-all.yaml`
- Below is an example netplan file, you may need to adjust the values depending on your system:
```
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens160:
      addresses:
      - 192.168.0.2/24
      nameservers:
        addresses:
        - 10.128.242.90
        - 8.8.8.8
      routes:
        - to: 0.0.0.0/0
          via: 192.168.0.1
```

- Enter `sudo netplan apply` to apply network settings

**Note:** It is a good practice to save your base vm or vapp template at this point.

## Download required files and prepare vars

- Login to your Ubuntu VM environment, all subsequent steps in these instructions should be completed from your ubuntu desktop environment.
- Unless otherwise instructed, all commands should be executed from the user's home directory

### Clone the ovathetap repo

- Execute the following commands:
```sh
# Install git, which is needed to clone the ovathetap repo
sudo apt update
sudo apt install git -y
# Navigate to the home directory
cd ~
git clone https://github.com/afewell/ovathetap.git
```

### Prepare Install Variables & Secrets 

To execute the scripts and instructions on this page, you will need to verify the values in the environmental variables file and update if needed. You will also need to enter required values in the secrets file with your docker and tanzunet account details - secrets are only used in your local environment. 

- REQUIRED: you must make copies of the vars and secrets templates, using the path and filenames specified below, as these files will be used in instructions and scripts throughout this document.
```sh
# If not already set in your env, set the hostusername var before executing the following commands
## Convention on this repo is to not use leading or trailing forward slashes in vars if possible
hostusername="$(whoami)"
home_dir="home/${hostusername}"
ovathetap_home="${home_dir}/ovathetap"
# create an ovathetap/config directory to hold customized local-only files - this dir is gitignored
mkdir -p /${ovathetap_home}/config
# REQUIRED: Make a copy of the cars template
cp "/${ovathetap_home}/scripts/inputs/vars.env.sh.template" "/${ovathetap_home}/config/vars.env.sh"
# Use nano or your preferred text editor to verify and, if needed, modify the default variables file
nano "/${ovathetap_home}/config/vars.env.sh"
# REQUIRED: Make a copy of the secrets template
cp "/${ovathetap_home}/scripts/inputs/secrets.env.sh.template" "/${ovathetap_home}/config/secrets.env.sh"
# REQUIRED: Use nano or your preferred text editor to populate the variables in the secrets.env.sh file
nano "/${ovathetap_home}/config/secrets.env.sh"
```

### Download Tanzu Application Platform

- go to https://network.tanzu.vmware.com/products/tanzu-application-platform
- login
- select version (This document was last updated for TAP 1.4.0)
- download the following files to the `~/Downloads` directory
  - Tanzu Developer Tools for Visual Studio Code 
  - Tanzu App Accelerator Extension for Visual Studio Code
  - learning-center-workshop-samples.zip file
  - Tanzu Application Platform GUI Yelb Catalog
  - tanzu-framework-bundle-linux

### Download Cluster Essentials

- go to https://network.tanzu.vmware.com/products/tanzu-cluster-essentials/
- login
- download the cluster essentials 1.4.0 bundle for linux to the `~/Downloads` directory

### Install all items in taphostprep-1.sh to setup/configure linux environment
- Ensure that the [environmental variables](${ovathetap_home}/config/vars.env.sh) are verified before proceeding.
- when you execute the commands below you will be prompted to select yes to install several different packages, install all of them
- if you prefer to install all packages without being prompted for input, you can add the "-u" flag, but its good to go through the interactive mode at least the first time so you can better understand what the script does.
```sh
# If you are using a custom hostusername, you should ensure the {hostusername} variable set in your environment and in the vars.env.sh file before proceeding
# The following statement sets the {hostusername} variable to whatever it is already set to, if it has already been set. If the hostusername variable is not already set, it sets it to the value that is to the right of the ":-" characters, which is "viadmin"
export hostusername="$(whoami)"
# source the vars files to ensure they are available in your env
source "/home/${hostusername}/ovathetap/config/vars.env.sh"
# source the secrets files to ensure they are available in your env. Note that since we sourced the vars file above, we can start using project variables to simplify and clarify ongoing commands
source "/${ovathetap_home}/config/secrets.env.sh"
# initialize temporary directory to be used for setup
mkdir -p "/${script_tmp_dir}"
# make the taphostprep-1.sh script executable
sudo chmod +x "/${ovathetap_scripts}/compound/taphostprep-1.sh"
# execute the taphostprep-1.sh file. Optionally append "-u" to install all packages in non-interactive mode
sudo "/${ovathetap_scripts}/compound/taphostprep-1.sh" # "-u"
```
- **IMPORTANT:** After the script completes, enter the following commands to enable sudoless docker calls. This is not just for user experience, it is required for subsequent steps to complete successfully.
```sh
sudo groupadd docker -f
sudo usermod -aG docker ${hostusername}
newgrp docker
```
- **IMPORTANT:** Reboot the host before proceeding
- After rebooting your host, verify you can execute docker commands without sudo by executing the command `docker run hello-world`
- verify vscode was installed and add it to the favorites bar

### Install CA Cert in Firefox to trust local sites

- Open firefox, navigate to settings and in the settings search window, search for "certificates"
- Select "View Certificates"
- Select "Import"
- Select "Other Locations"
- Navigate to the /etc/ssl/CA/ directory, select the myca.pem file and click open to import the certificate
- Select the options to Trust this CA for websites and email addresses and click ok to finish importing the certificate
- Close firefox settings

### Initialize Visual Studio Code
- Open VS Code
- Add to the Ubuntu favorites bar
- exit the "Get Started with VS Code" wizard
- Open Folder to the /home/viadmin directory

### Deploy Minikube Cluster
```sh
export hostusername="$(whoami)"
# source the vars files again since you should have rebooted after running taphostprep-1.sh
source "/home/${hostusername}/ovathetap/config/vars.env.sh"
# source the secrets files to ensure they are available in your env. Note that since we sourced the vars file above, we can start using project variables to simplify and clarify ongoing commands
source "/${ovathetap_home}/config/secrets.env.sh"
# Start Minikube
minikube start --kubernetes-version="${kubernetes_version}" --memory="${minikube_memory}" --cpus="${minikube_cpus}" --driver=docker --embed-certs --insecure-registry=0.0.0.0/0
# Gather minikube IP
echo "the minikube ip is: $(minikube ip)"
export minikubeip=$(minikube ip)
```

### Setup MetalLB

- Before deploying metallb, add your docker hub credentials so the images are downloaded using an authenticated account
```sh
# Login to docker to assist with docker hub rate limiting
## This is important to help prevent rate limiting issues, even if you have a free account
docker login -u "${docker_account_username}" -p "${docker_account_password}"
# create namespace for harbor
kubectl create ns metallb-system
# Create a kubernetes secret with your docker credentials
kubectl create secret generic myregistrykey \
    --from-file=.dockerconfigjson="/home/${hostusername}/.docker/config.json" \
    --type=kubernetes.io/dockerconfigjson -n metallb-system
# Attach the secret with your docker credentials to the default service account for the harbor namespace
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "myregistrykey"}]}' -n metallb-system
minikube addons enable metallb
minikube addons configure metallb
```
- Enter Load Balancer Start IP: `192.168.49.5`
- Enter Load Balancer End IP: `192.168.49.25`
- Enter the following commands to add the imagePullSecrets to the metallb installation:
```sh
# patch the metallb controller deployment yaml with the imagePullSecrets
kubectl patch deployment controller -p '{"spec": {"template": {"spec": {"imagePullSecrets": [{"name": "myregistrykey"}]}}}}' -n metallb-system
# patch the metallb controller deployment yaml with the imagePullSecrets
kubectl patch daemonset speaker -n my-namespace -p '{"spec": {"template": {"spec": {"imagePullSecrets": [{"name": "myregistrykey"}]}}}}' -n metallb-system
```
- Validate metallb installation:
  - `kubectl get all -n metallb-system`
  - verify all of the objects are deployed correctly, if all objects appear to have deployed correctly, please proceed to the next section
- If your pods are not deploying:
  - In several tests, the metallb containers did not seem to use the default SA or for whatever reason, dont use the imagePullSecret and might get blocked by docker hub limits.
  - To resolve this issue

### Complete dnsmasq configuration
```sh
## Configure dnsmasq to resolve every request to *.tanzu.demo to the minikube IP
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.old
sudo echo "address=/harbor.tanzu.demo/192.168.49.5" | sudo tee /etc/dnsmasq.conf
sudo echo "address=/tanzu.demo/192.168.49.6" | sudo tee -a /etc/dnsmasq.conf
sudo systemctl restart dnsmasq
echo "dnsmasq configuration complete"
```

### Install Harbor
```sh
envsubst < "/${ovathetap_assets}/harborvalues.yaml.template" > "/${ovathetap_home}/config/harborvalues.yaml"
## Install Harbor
# Login to docker to assist with docker hub rate limiting
## This is important to help prevent rate limiting issues, even if you have a free account
docker login -u "${docker_account_username}" -p "${docker_account_password}"
# create namespace for harbor
kubectl create ns harbor
# Create a kubernetes secret with your docker credentials
kubectl create secret generic myregistrykey \
    --from-file=.dockerconfigjson="/home/${hostusername}/.docker/config.json" \
    --type=kubernetes.io/dockerconfigjson -n harbor
# Attach the secret with your docker credentials to the default service account for the harbor namespace
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "myregistrykey"}]}' -n harbor
# Add the harbor repo to helm
helm repo add harbor https://helm.goharbor.io
# create secret for harbor tls certificate
kubectl create secret tls harbor-cert --key /etc/ssl/CA/harbor.tanzu.demo.key --cert /etc/ssl/CA/harbor.tanzu.demo.crt -n harbor
# install harbor
helm install harbor harbor/harbor -f "/${ovathetap_home}/config/harborvalues.yaml" -n harbor
```
- **IMPORTANT:** It may take several minutes before the harbor deployment completes. Please ensure the harbor deployment is fully running before proceeding with the following verification steps:
  - enter the command `watch kubectl get deployments -n harbor` and wait for all of the deployments to be ready before proceeding
  - Open a tab in firefox and navigate to the url `https://harbor.tanzu.demo` and verify the harbor login page is displayed
  - Add the harbor login screen to firefox bookmarks toolbar
  - Navigate to manage bookmarks, and remove "Getting Started" from the bookmarks toolbar
  - Login to the harbor web interface with the username `admin` and password `Harbor12345`
  - Verify you can also login from your terminal with the command `docker login harbor.tanzu.demo` - enter the username `admin` and password `Harbor12345` when prompted.
  - If any of these steps do not work, wait a few minutes and try again. Ensure these verification steps work before proceeding. 

### Install Tanzu CLI
```sh
## Install Tanzu CLI
cd "/${home_dir}/Downloads"
# create a directory to unzip the tanzu CLI files to
mkdir -p "/${tanzu_cli_dir}"
# unzip the file and install Tanzu CLI
tar -xvf "${tanzu_cli_bundle_filename}" -C "/${tanzu_cli_dir}"
export TANZU_CLI_NO_INIT=true
cd "/${tanzu_cli_dir}" 
export VERSION=${tanzu_cli_version}
sudo install "cli/core/$VERSION/tanzu-core-linux_amd64" /usr/local/bin/tanzu
tanzu plugin install --local cli all
```

### Install Tanzu Cluster Essentials
```sh
# Create kapp-controller-config secret manifest
sudo sed 's/^/    /' "/etc/ssl/CA/myca.pem" | sudo tee "/${script_tmp_dir}/myca-indented.pem"
sudo sed "/caCerts/ r /${script_tmp_dir}/myca-indented.pem" "/${ovathetap_assets}/kapp-controller-config.yaml.template" | sudo tee "/${ovathetap_home}/config/kapp-controller-config.yaml"
sudo rm "/${script_tmp_dir}/myca-indented.pem"
## Install Cluster Essentials
cd "/${home_dir}/Downloads" 
# create a directory to unzip the tap installer files to
mkdir -p "/${cluster_essentials_dir}" 
# unzip the file and install cluster essentials
tar -xvf "${cluster_essentials_bundle_filename}" -C "/${cluster_essentials_dir}" 
kubectl create namespace kapp-controller
kubectl apply -f "/${ovathetap_home}/config/kapp-controller-config.yaml"
export INSTALL_BUNDLE="${cluster_essentials_bundle_url}"
export INSTALL_REGISTRY_HOSTNAME="${tanzunet_hostname}"
export INSTALL_REGISTRY_USERNAME="${tanzunet_username}"
export INSTALL_REGISTRY_PASSWORD="${tanzunet_password}"
cd "/${cluster_essentials_dir}"
./install.sh --yes
# add carvel apps to path
sudo cp "/${home_dir}/tanzu-cluster-essentials/kapp" /usr/local/bin/kapp
sudo cp "/${home_dir}/tanzu-cluster-essentials/imgpkg" /usr/local/bin/imgpkg
sudo cp "/${home_dir}/tanzu-cluster-essentials/kbld" /usr/local/bin/kbld
sudo cp "/${home_dir}/tanzu-cluster-essentials/ytt" /usr/local/bin/ytt
```


### Relocate TAP images to the local Harbor registry
- **IMPORTANT** use firefox and login to the harbor portal (https://harbor.tanzu.demo). Create a new project named "tap" with public access
  - Note: It should work just fine if you set it for private access, I just set it for public because my use case is in a private nested lab environment with no inbound access
```sh
## Relocate TAP Images to your install registry
export INSTALL_REGISTRY_USERNAME=admin
export INSTALL_REGISTRY_PASSWORD=Harbor12345
export INSTALL_REGISTRY_HOSTNAME=harbor.tanzu.demo
export TAP_VERSION="${tap_version}"
export INSTALL_REPO="${tap_install_repo}"
docker login $INSTALL_REGISTRY_HOSTNAME -u $INSTALL_REGISTRY_USERNAME -p $INSTALL_REGISTRY_PASSWORD
docker login "${tanzunet_hostname}" -u "${tanzunet_username}" -p "${tanzunet_password}"
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages
```

### Install TAP
```sh
## Prepare and inject local ca cert into ca_cert_data key in tap-values.yaml file
sudo sed 's/^/    /' "/etc/ssl/CA/myca.pem" | sudo tee "/${script_tmp_dir}/myca-indented.pem"
sudo sed "/ca_cert_data/ r /${script_tmp_dir}/myca-indented.pem" "/${ovathetap_assets}/tap-values.yaml.template" | sudo tee "/${ovathetap_home}/config/tap-values.yaml"
sudo rm "/${script_tmp_dir}/myca-indented.pem"
## Install TAP
# create tap-install namespace
kubectl create ns tap-install
export INSTALL_REGISTRY_USERNAME=admin
export INSTALL_REGISTRY_PASSWORD=Harbor12345
export INSTALL_REGISTRY_HOSTNAME=harbor.tanzu.demo
export TAP_VERSION="${tap_version}"
export INSTALL_REPO="${tap_install_repo}"
docker login $INSTALL_REGISTRY_HOSTNAME -u $INSTALL_REGISTRY_USERNAME -p $INSTALL_REGISTRY_PASSWORD
tanzu secret registry add tap-registry \
  --username ${INSTALL_REGISTRY_USERNAME} --password ${INSTALL_REGISTRY_PASSWORD} \
  --server ${INSTALL_REGISTRY_HOSTNAME} \
  --export-to-all-namespaces --yes --namespace tap-install
tanzu package repository add tanzu-tap-repository \
  --url ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages:$TAP_VERSION \
  --namespace tap-install
```
- The Tanzu Package Repository should reconcile before proceeding
- Prepare for cert-manager installation
  - Cert-manager will be automatically installed as part of the TAP installation. But we want it to use a custom issuer based on our CA certificate. So here we will preinstall the tanzu package for cert manager per https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/cert-manager-install.html
```sh
# Determine the tanzu package version number for cert-manager in your tap installation
tanzu package available list cert-manager.tanzu.vmware.com -n tap-install | grep -o '[0-9]*\.[0-9]*\.[0-9]*'
export certmantanzupackageversion=$(tanzu package available list cert-manager.tanzu.vmware.com -n tap-install | grep -o '[0-9]*\.[0-9]*\.[0-9]*')
# Determine cert-manager version used in by the tanzu package for cert-manager in your environment
kubectl get package -n tap-install cert-manager.tanzu.vmware.com.${certmantanzupackageversion} -ojsonpath='{.spec.includedSoftware}' | jq -r '.[].version'
export certmanversion=$(kubectl get package -n tap-install cert-manager.tanzu.vmware.com.${certmantanzupackageversion} -ojsonpath='{.spec.includedSoftware}' | jq -r '.[].version')
# Create cert-manager namespace
kubectl create ns cert-manager
# create cert manager cluster role and seervice account
kubectl apply -f "/${ovathetap_assets}/cert-manager-rbac.yaml"
# prepare cert manager install file
envsubst < "/${ovathetap_assets}/cert-manager-install.yaml.template" > "/${ovathetap_home}/config/cert-manager-install.yaml"
# Install cert-manager
kubectl apply -f "/${ovathetap_home}/config/cert-manager-install.yaml"
# Create secret from CA cert
kubectl create secret tls my-ca-secret --key /etc/ssl/CA/myca.key --cert /etc/ssl/CA/myca.pem -n cert-manager
# Create clusterIssuer yaml file based on lab CA cert secret
cat << EOF > "/${ovathetap_home}/config/my-ca-issuer.yaml"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: my-ca-issuer
spec:
  ca:
    secretName: my-ca-secret
EOF
# Create the ClusterIssuer with the following command
kubectl apply -f "/${ovathetap_home}/config/my-ca-issuer.yaml" -n cert-manager
# Verify the cluster issuer was created and is ready with the following command:
kubectl get ClusterIssuer
# Install TAP
tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION --values-file "/${ovathetap_home}/config/tap-values.yaml" -n tap-install
```
- IF your tap installation fails, it may be because some packages are still reconciling.
- Check on the status of each package install to find the issue:
  - `kubectel get packageinstalls -n tap-install`
- Do not proceed until the tap install completes reconciling successfully

```sh
# Install Full Dependencies Package
## Get buildservice version number
tanzu package available list buildservice.tanzu.vmware.com --namespace tap-install
export BSVersion=$(tanzu package available list buildservice.tanzu.vmware.com --namespace tap-install | awk '{print $2}' | tail -n 1)
echo $BSVersion
## Relocate full dependencies packages to your install repo
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/full-tbs-deps-package-repo:$BSVersion \
  --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tbs-full-deps
## Add the full dependencies package
tanzu package repository add tbs-full-deps-repository \
  --url ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tbs-full-deps:$BSVersion \
  --namespace tap-install
tanzu package install full-tbs-deps -p full-tbs-deps.tanzu.vmware.com -v $BSVersion -n tap-install
tanzu package installed update tap -p tap.tanzu.vmware.com -v $TAP_VERSION  --values-file "/${ovathetap_home}/config/tap-values.yaml" -n tap-install
add steps to validate tap install
```


### Configure Ingress for Harbor

### Install Cert-Manager
**This needs to be updated to reflect install from tanzu package**
```sh
kubectl create ns cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
```

### Create a kubernetes secret with your CA certificates

```sh
kubectl create secret tls my-ca-secret --key /etc/ssl/CA/myca.key --cert /etc/ssl/CA/myca.pem -n cert-manager
``` 

### Create a cert-manager ClusterIssuer using your CA secret

- create a file ca-issuer.yaml with the following text:
```sh
cat << EOF > "/${ovathetap_home}/config/ca-issuer.yaml"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  ca:
    secretName: my-ca-secret
EOF
# Create the ClusterIssuer with the following command
kubectl apply -f "/${ovathetap_home}/config/ca-issuer.yaml" -n cert-manager
# Verify the cluster issuer was created and is ready with the following command:
kubectl get ClusterIssuer
```


<!-- I dont know if we need minikube tunnel so testing without it this round. 
### Start Minikube tunnel

- `minikube tunnel`
- it may ask you to enter your password
- the process will take over the terminal session, so you will need to open a new terminal window to continue, leave the minikube tunnel terminal session open -->

### (Optional) Install Gitlab
- This lab can support github or gitlab, if you are using github, you can skip this section
- Install Gitlab
```sh
# prep and post the gitlab values template to the config directory
envsubst < "/${ovathetap_home}/assets/gitlab-values.yaml.template" > "/${ovathetap_home}/config/gitlab-values.yaml"
# Install Gitlab 
helm upgrade --install gitlab gitlab/gitlab -n gitlab -f "/${ovathetap_home}/config/gitlab-values.yaml"
```
- The values specified in the gitlab-values.yaml file disabled several default items from the gitlab helm chart. This is partially because we only need to access basic git repository features in gitlab, and do not need to install extended features. In addition, the ingress generation was disabled as the intent for this environment is to use the contour ingress controller included with the TAP installation for all ingress services. 









<!--
Modify the learningcenter-portal ingress object to get cert from cert-manager
- need to add annotations and tls sections
- file saved to v4 branch in scripts/assets/tap/1_3/test_v3/learningcenter-portal-ingress.yaml

 this should already be addressed in the initial install steps, once verified, delete this commented step
#### Setup Ingress for tap-gui

tanzu package installed update tap -p tap.tanzu.vmware.com -v $TAP_VERSION  --values-file /${ovathetap_home}/config/tap-values.yaml -n tap-install -->


