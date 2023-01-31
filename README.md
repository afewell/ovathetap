# This lab is under active development and the instructions probably will not work right now as I still have a lot of changes that I need to make which are in-progress
# OvaTheTap
The purpose of this document is to create a complete Full Profile installation for Tanzu Application Platform on a single VM.

The project is currently focused on a single environment topology, using a single, minimal ubuntu desktop VM to install kubernetes and TAP on a single host. The instructions and assets provided here should work on an ubuntu host with sufficient resources and performance, regardless of whether it is on bare metal or any virtualization platform, but the user may need to adjust some values for different environments.

This repository provides instructions and may include content with dependencies on licensed software. This repository does not provide any licensing or access to any licensed products that are referenced within. Shousld anyone attempt to use any information or content within this repository, it is that users responibility to comply with all licensing requirements.

The contents of this repository are intended for educational purposes only. Any software configuration references provided are intended for non-production environments and should not be used in any production environment or depended upon in any way. The configuration referenced within is explicitly not supported, and any contributor to this repository does not provide any assurance that any design, configuration or other information/content within should work or function properly in any way. 

# TAP 1.4 Single-node Lab Install Flow

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
# REQUIRED: Make a copy of the vars template
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
source "/${ovathetap_config}/secrets.env.sh"
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
source "/${ovathetap_config}/secrets.env.sh"
# Start Minikube
minikube start --kubernetes-version="${kubernetes_version}" --memory="${minikube_memory}" --cpus="${minikube_cpus}" --driver=docker --embed-certs --insecure-registry=0.0.0.0/0 --extra-config=kubelet.max-pods=200
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
helm install harbor harbor/harbor -f "/${ovathetap_config}/harborvalues.yaml" -n harbor
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
sudo sed "/caCerts/ r /${script_tmp_dir}/myca-indented.pem" "/${ovathetap_assets}/kapp-controller-config.yaml.template" | sudo tee "/${ovathetap_config}/kapp-controller-config.yaml"
sudo rm "/${script_tmp_dir}/myca-indented.pem"
## Install Cluster Essentials
cd "/${home_dir}/Downloads" 
# create a directory to unzip the tap installer files to
mkdir -p "/${cluster_essentials_dir}" 
# unzip the file and install cluster essentials
tar -xvf "${cluster_essentials_bundle_filename}" -C "/${cluster_essentials_dir}" 
kubectl create namespace kapp-controller
kubectl apply -f "/${ovathetap_config}/kapp-controller-config.yaml"
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
# Create the "tap" project on Harbor - this is where the TAP images will be stored
curl -u $INSTALL_REGISTRY_USERNAME:$INSTALL_REGISTRY_PASSWORD \
-X POST "https://$INSTALL_REGISTRY_HOSTNAME/api/projects" \
-H "Content-Type: application/json" \
-d '{"project_name":"tap", "public":1}'
docker login $INSTALL_REGISTRY_HOSTNAME -u $INSTALL_REGISTRY_USERNAME -p $INSTALL_REGISTRY_PASSWORD
docker login "${tanzunet_hostname}" -u "${tanzunet_username}" -p "${tanzunet_password}"
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages
```

### Install TAP
```sh
## Prepare and inject local ca cert into ca_cert_data key in tap-values.yaml file
sudo sed 's/^/    /' "/etc/ssl/CA/myca.pem" | sudo tee "/${script_tmp_dir}/myca-indented.pem"
sudo sed "/ca_cert_data/ r /${script_tmp_dir}/myca-indented.pem" "/${ovathetap_assets}/tap-values.yaml.template" | sudo tee "/${ovathetap_config}/tap-values.yaml"
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
envsubst < "/${ovathetap_assets}/cert-manager-install.yaml.template" > "/${ovathetap_config}/cert-manager-install.yaml"
# Install cert-manager
kubectl apply -f "/${ovathetap_config}/cert-manager-install.yaml"
# Create secret from CA cert
kubectl create secret tls my-ca-secret --key /etc/ssl/CA/myca.key --cert /etc/ssl/CA/myca.pem -n cert-manager
# Create clusterIssuer yaml file based on lab CA cert secret
cat << EOF > "/${ovathetap_config}/my-ca-issuer.yaml"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: my-ca-issuer
spec:
  ca:
    secretName: my-ca-secret
EOF
# Create the ClusterIssuer with the following command
kubectl apply -f "/${ovathetap_config}/my-ca-issuer.yaml" -n cert-manager
# Verify the cluster issuer was created and is ready with the following command:
kubectl get ClusterIssuer
# Install TAP
tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION --values-file "/${ovathetap_config}/tap-values.yaml" -n tap-install
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
tanzu package installed update tap -p tap.tanzu.vmware.com -v $TAP_VERSION  --values-file "/${ovathetap_config}/tap-values.yaml" -n tap-install
# confirm tap installation - all items should be in state reconcile succeeded
kubect get packageinstalls -n tap-install
tanzu package installed list -n tap-install
```
- Using firefox, open a browser tab to https://tap-gui.tanzu.demo
  - Note that the GUI is still fairly empty at this point as we will add the catalog and other assets in subsequent steps.
- Bookmark this page on the bookmarks bar

### Install Gitlab
TODO: On next test, attempt to specify gitlab initial root password in helm values file, which MAY automatically create root access token and if so, then we can bypass the requirement to manually create the token in the gui. And parameterize values files.
- The instructions for this lab focus on using gitlab. However if you prefer, you can use github instead, but instructions for using github are not provided.
- Install Gitlab
```sh
# create gitlab namespace
kubectl create ns gitlab
# add docker hub login info for pulling minio chart
docker login -u "${docker_account_username}" -p "${docker_account_password}"
kubectl create secret generic myregistrykey \
    --from-file=.dockerconfigjson="/home/${hostusername}/.docker/config.json" \
    --type=kubernetes.io/dockerconfigjson -n gitlab
# Install Gitlab helm chart
helm repo add gitlab https://charts.gitlab.io/
helm repo update
# Install Gitlab
helm upgrade --install gitlab gitlab/gitlab -n gitlab -f "/${ovathetap_assets}/gitlab-values.yaml"
```
- The values specified in the gitlab-values.yaml file disabled several default items from the gitlab helm chart. This is partially because we only need to access basic git repository features in gitlab, and do not need to install extended features. In addition, the ingress generation was disabled as the intent for this environment is to use the contour ingress controller included with the TAP installation for all ingress services.
```sh
# Create ingresses for gitlab
kubectl apply -f "/${ovathetap_assets}/gitlab-ingresses.yaml"
# Verify Gitlab Deployment
kubectl get all -n gitlab
```
- Get the initial gitlab root login password:
  - `kubectl get secrets -n gitlab gitlab-gitlab-initial-root-password -o jsonpath={.data.password} | base64 -d`
  - Enter this password into the secrets.env.sh file
- Using firefox, open a browser tab to https://gitlab.tanzu.demo
  - Login with account:
    - Username: root
    - Password: enter the password you gathered from the secret
  - Bookmark this page on the bookmarks bar
- Click on the icon for the logged in account in the upper right corner of the web ui and select preferences.
- Click `Access Tokens`
- Create a token with the following settings: 
  - Token name: root
  - Expiration Date: any future date
  - Scopes: api
  - Click `Create personal access token`
- Copy Personal Access Token and paste into secrets.env.sh file
  - Source the secrets file to load the password environment variable
  - `source "/${ovathetap_config}/secrets.env.sh`
- Enter the following commands to create a new user account for the viadmin user:
```sh
gitlab_viadmin_create_reponse=$(curl -k --request POST --header "PRIVATE-TOKEN: ${gitlab_root_token}" --data 'email=viadmin@tanzu.demo&username=viadmin&password=VMware1!&name=VI Admin&admin=true&skip_confirmation=true' https://gitlab.tanzu.demo/api/v4/users)
echo ${gitlab_viadmin_create_reponse} | yq -p json -o yaml | tee "/${ovathetap_config}/gitlab_viadmin_account_details.yaml"
export gitlab_viadmin_user_id=$(echo ${gitlab_viadmin_create_reponse} | jq -r '.id')
echo "export gitlab_viadmin_user_id=${gitlab_viadmin_user_id}" >> "/${ovathetap_config}/vars.env.sh"
# create access token for viadmin user
viadmin_gitlab_token_create_response=$(curl --request POST --header "PRIVATE-TOKEN: ${gitlab_root_token}" --data "name=mytoken" --data "expires_at=2025-04-04" \
     --data "scopes[]=api" "https://gitlab.tanzu.demo/api/v4/users/${gitlab_viadmin_user_id}/personal_access_tokens")
echo ${viadmin_gitlab_token_create_response}
export viadmin_gitlab_token=$(echo ${viadmin_gitlab_token_create_response} | jq -r '.token')
echo "export viadmin_gitlab_token=${viadmin_gitlab_token}" >> "/${ovathetap_config}/vars.env.sh"
```
- Enter the following commands to create a new user account for the devlead user:
```sh
gitlab_viadmin_create_reponse=$(curl -k --request POST --header "PRIVATE-TOKEN: ${gitlab_root_token}" --data 'email=devlead@tanzu.demo&username=devlead&password=VMware1!&name=Dev Lead&admin=true&skip_confirmation=true' https://gitlab.tanzu.demo/api/v4/users)
echo ${gitlab_devlead_create_reponse} | yq -p json -o yaml | tee "/${ovathetap_config}/gitlab_devlead_account_details.yaml"
export gitlab_devlead_user_id=$(echo ${gitlab_devlead_create_reponse} | jq -r '.id')
echo "export gitlab_devlead_user_id=${gitlab_devlead_user_id}" >> "/${ovathetap_config}/vars.env.sh"
# create access token for viadmin user
devlead_gitlab_token_create_response=$(curl --request POST --header "PRIVATE-TOKEN: ${gitlab_root_token}" --data "name=mytoken" --data "expires_at=2025-04-04" \
     --data "scopes[]=api" "https://gitlab.tanzu.demo/api/v4/users/${gitlab_devlead_user_id}/personal_access_tokens")
echo ${devlead_gitlab_token_create_response}
export devlead_gitlab_token=$(echo ${devlead_gitlab_token_create_response} | jq -r '.token')
echo "export devlead_gitlab_token=${devlead_gitlab_token}" >> "/${ovathetap_config}/vars.env.sh"
```
- create gitlab oauth app
```sh
create_oauth_app_response=$(curl -k --request POST --header "PRIVATE-TOKEN: ${gitlab_root_token}" \
     --data "name=tap&redirect_uri=https://tap-gui.tanzu.demo/api/auth/gitlab/handler/frame&scopes=api read_api read_user read_repository write_repository read_registry write_registry sudo openid profile email" \
     "https://gitlab.tanzu.demo/api/v4/applications")
echo ${create_oauth_app_response} | yq -p json -o yaml | tee "/${ovathetap_config}/gitlab_oauth_app_config.yaml"
```
#### create catalog repo
- From firefox, login as viadmin
- Click `Create a group` and then `Create group` to create a group with the following settings (leave any unspecified setting at its default value):
  - Group name: tanzu
  - Visibility level: Public
  - Role: Devops Engineer
  - Who will be using this group?: My company or team
  - Click `Create group`
- Click `Create new project` and then `Create a blank project` - use the following settings (leave any unspecified setting at its default value):
  - Project name: tap-catalog
  - Visibility Level: Public
  - Initialize repository with a README: true
  - Click `Create project`
- upload catalog files to repository:
```sh
# Setup your local git client
git config --global user.name "viadmin"
git config --global user.email "viadmin@gitlab.tanzu.demo"
cd ~
git clone https://gitlab.tanzu.demo/tanzu/tap-catalog.git
# unpack tap catalog files to tap-catalog directory
tar -xvzf "/home/${hostusername}/Downloads/tap-gui-yelb-catalog.tgz" -C "/home/${hostusername}/"
cp -r "/home/${hostusername}/yelb-catalog/"* "/home/${hostusername}/tap-catalog/"
cd "/home/${hostusername}/tap-catalog/"
git add .
git commit -m "adding yelb catalog files"
git push
# after entering `git push' enter username: viadmin password: VMware1!
```

# Create a manifest for the config secret
```sh
cat <<EOF > "/${ovathetap_config}/envoy-gitlab-ssh-config.yaml"
apiVersion: v1
kind: Secret
metadata:
  name: envoy-gitlab-ssh-config-secret
  namespace: tap-install
stringData:
  patch.yaml: |
    #@ load("@ytt:overlay", "overlay")
    #@overlay/match by=overlay.subset({"kind":"Service","metadata":{"namespace":"tanzu-system-ingress", "name":"envoy"}})
    ---
    spec:
      #@overlay/match missing_ok=True
      ports:
        - name: gitlab-shell
          port: 22
          protocol: TCP
          targePort: gitlab-shell
EOF
# deploy the secret in your kubernetes cluster:
kubectl create -f "/${ovathetap_config}/envoy-gitlab-ssh-config.yaml"
```

```sh
package_overlays:
  - name: "contour"
    secrets:
    - name: "envoy-gitlab-ssh-config-secret"
```

#### Update tap with gitlab settings
```sh
## Prepare and inject local ca cert into ca_cert_data key in tap-values-2.yaml file
sudo sed 's/^/    /' "/etc/ssl/CA/myca.pem" | sudo tee "/${ovathetap_config}/myca-indented.pem"
sudo sed "/ca_cert_data/ r /${ovathetap_config}/myca-indented.pem" "/${ovathetap_assets}/tap-values-2.yaml.template" | sudo tee "/${ovathetap_config}/tap-values-2.yaml"
sudo rm "/${ovathetap_config}/myca-indented.pem"
# update tap with new values 
tanzu package installed update tap -p tap.tanzu.vmware.com -v $TAP_VERSION  --values-file "/${ovathetap_config}/tap-values-2.yaml" -n tap-install
```

#### Create Developer Namespace

- Create a developer namespace
  - In Tanzu Application Platform, a developer namespace is a kubernetes namespace that uses the namespace provisioner (or alternative gitops method) to ensure that additional resources are created in the namespace such as a service account, role-binding, and registry credentials. These resources are needed to ensure the developer has an optimal user experience and can initiate supply chain and developer workflows. 
```sh
kubectl create ns viadmin
kubectl label namespaces viadmin apps.tanzu.vmware.com/tap-ns=""
```

#### Install Tanzu Developer Tools

- Open VS Code.
- Press cmd+shift+P to open the Command Palette and run Extensions: Install from VSIX....
- Select the extension file tanzu-vscode-extension.vsix which is located in the ~/Downloads directory.
- Install the following extensions from VS Code Marketplace:
  - Debugger for Java
  - Language Support for Java(™) by Red Hat
  - YAML
  - Spring Boot Extension Pack
- Configure Tanzu Dev Tools Extension
  - Go to Code > Preferences > Settings > Extensions > Tanzu Developer Tools and set the following:
  - Enable Live Hover
  - Source Image: (Required) The registry location for publishing local source code. For example, registry.io/yourapp-source. This must include both a registry and a project name.
  - Local Path: (Optional) The path on the local file system to a directory of source code to build. This is the current directory by default.
  - Namespace: (Optional) This is the namespace that workloads are deployed into. The namespace set in kubeconfig is the default.
- Reload VS Code for this change to take effect.


- Open VS Code.
- Press cmd+shift+P to open the Command Palette and run Extensions: Install from VSIX....
- Select the extension file tanzu-app-accelerator-0.1.5.vsix which is located in the ~/Downloads directory to install.
- Configure Extension
  - Go to Code > Preferences > Settings > Extensions > Tanzu App Accelerator and set the following:
  - Set the Tap GUI backend URL to `https://tap-gui.tanzu.demo`
- Reload VS Code for this change to take effect.


Exercises:
TODO:
devlead executes accelerator including auto git repo creation
devlead modifies code, uses app live view
devlead deploys code through scanning and testing pipeline
devlead reviews screens and/or commands that show details of the supply chain operations

devlead reviews whatever screens are available to review deployment
devlead executes update to app that is already deployed

story: devlead requests new accelerator

viadmin makes new accelerator

devlead executes new accelerator
















<!--
This is a hidden section at the bottom of the file to place work in progress that is still desireable, but could not be completed yet for some reason

# Gitlab SSH Key registration with curl
## The current workflow has users manually register their ssh key in the gui because I could not get the api call to work
## The snippet below represents some of the things I tried, I tried dozens and dozens of different permutations and couldnt get anything to work. I got back a wide variety of strange responses including several times I got back unauthorized even when using a root token that I gave every possible permission to, and trying to post as viadmin to viadmin account I still got unauthorized or bad request or other errors. Would be nice to automate at some point, leaving wip below:

- setup ssh keys for viadmin - curl
```sh
# create ssh key
ssh-keygen -t ed25519 -f "/home/${hostusername}/.ssh/id_ed25519" -N ""
ssh-keygen -t rsa -b 2048 -f "/home/${hostusername}/.ssh/id_rsa" -N ""
mysshkey=$(cat "/home/${hostusername}/.ssh/id_ed25519.pub")
# add the ssh key for viadmin to gitlab using an API call
## prepare a json snippet for the api call - populate vars
cat << EOF > "/${ovathetap_config}/gitlab_ssh_api_call_data.json"
{
  "title": "ABC",
  "key": "${mysshkey}",
  "expires_at": "$(date --date="+1 year" +"%Y-%m-%dT00:00:00.000Z")",
  "usage_type": "auth"
}
EOF
## save json snippet as a envar
export gitlab_ssh_api_call_data=$(cat "/${ovathetap_config}/gitlab_ssh_api_call_data.json" | jq -c .) 
gitlab_ssh_api_call_response=$(curl -k --request POST --header "PRIVATE-TOKEN: ${gitlab_root_token}" \
     --data "title=viadmin@ubuntudesktop&key=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDcXE8lvSb41zO4UOcTks4wsKeZn8mKNbIcuptXuPIdNtYo2okTm0RpHOamCqsjNb5b0zWWRsoeyNnZ9HIcXGQH1ZeR62valOMMnCyHvua8wIMnz1heT4pr8BL4N8u3B6TgXgY38bQJjv7fBe9Fgp6aSGQ8kuQMeY0v70JfxvMIANiKwdXK5P52ADcUiJMlBl247J1QhJlLook7pSOoE7sHQgYo8KN7UE8fc8/9HCGXakZtPTvjA7vf5EGhtyDEluK+dy+gtqKKaivNsDA6xoKD9ULDrCkvcvoX3FszeYGUQb1NqWzLKkOaC0i/Ts+ecJAPeHLdXPrqdqf1C7HbiqL/ viadmin@ubuntudesktop" \
     "https://gitlab.tanzu.demo/api/v4/users/${gitlab_viadmin_user_id}/keys")
echo "${gitlab_ssh_api_call_response}"


export gitlab_ssh_api_call_response=$(curl -k --request POST --header "Private-Token: {gitlab_root_token}" \
     --data {"title":"viadmin@ubuntudesktop","key":"${mysshkey}"} \
     https://gitlab.tanzu.demo/api/v4/users/${gitlab_viadmin_user_id}/keys)

export gitlab_ssh_api_call_response=$(curl -k --request POST --header "Private-Token: ${viadmin_gitlab_token}" --data {"title":"viadmin@ubuntudesktop","key":"${mysshkey}"} \
     https://gitlab.tanzu.demo/api/v4/user/keys)
```





 -->


