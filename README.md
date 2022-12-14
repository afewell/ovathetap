# OvaTheTap
The purpose of this document is to create a complete Full Profile installation for Tanzu Application Platform on a single VM.

The project is currently focused on a single environment topology, using a single, minimal ubuntu desktop VM to install kubernetes and TAP on a single host. The instructions and assets provided here should work on an ubuntu host with sufficient resources and performance, regardless of whether it is on bare metal or any virtualization platform, but the user may need to adjust some values for different environments.

# TAP 1.3 Single-node Lab Install Flow

## References:
- [1] https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3
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

## Clone the ovathetap repo

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

To execute the scripts and instructions on this page, you will need to verify the default environmental variables provided and update if needed. You will also need to complete the secrets file with your docker and tanzunet account details - this information is only used within the local scripts in your local environment. 

- Verify the [default environmental variables](./scripts/inputs/vars.env.sh)
- REQUIRED: you must make copies of the vars and secrets templates, using the path and filenames specified below, as these files will be used in instructions and scripts throughout this document.
```sh
# If not already set in your env, set the hostusername var before executing the following commands
## Convention on this repo is to not use leading or trailing forward slashes in vars if possible
hostusername="${hostusername}"
home_dir="home/${hostusername}"
ovathetap_home="${home_dir}/ovathetap"
# REQUIRED: Make a copy of the cars template
cp "/${ovathetap_home}/scripts/inputs/vars.env.sh.template" "/${ovathetap_home}/scripts/inputs/vars.env.sh"
# Use nano or your preferred text editor to verify and, if needed, modify the default variables file
nano "/${ovathetap_home}/scripts/inputs/vars.env.sh"
# REQUIRED: Make a copy of the secrets template
cp "/${ovathetap_home}/scripts/inputs/secrets.env.sh.template" "/${ovathetap_home}/scripts/inputs/secrets.env.sh"
# REQUIRED: Use nano or your preferred text editor to populate the variables in the secrets.env.sh file
nano "/${ovathetap_home}/scripts/inputs/secrets.env.sh"
# initialize temporary directory to be used for setup
mkdir "/${script_tmp_dir}"
```
- **Note:** You should never upload your populated secrets file to github. A gitignore file is included in the inputs directory to help prevent your secrets from being uploaded. 
- **VMWARE EMPLOYEES:** IF your lab environment is on a vmware internal network, please include the line `export vmware_int_net="true"` in the vars.env.sh file. This sets up the docker_proxy_cache, which can help bypass the crippling docker hub rate limits, but it only works from vmware internal networks. 

### Download  Tanzu CLI Bundle

- go to https://network.tanzu.vmware.com/products/tanzu-application-platform
- login
- download the tanzu CLI bundle for linux
- **IMPORTANT** the tanzu CLI bundle must be downloaded to /home/{hostusername}/Downloads. By default the {hostusername} is set to `viadmin`, make sure to change this value in the inputs file if you are using a different host username.
- Ensure that the [default environmental variables](./scripts/inputs/vars.env.sh) align with the Tanzu ClI version you plan to install. 


### Download Cluster Essentials

- go to https://network.tanzu.vmware.com/products/tanzu-cluster-essentials/
- login
- download the cluster essentials bundle for linux
- **IMPORTANT** The cluster essentials bundle must be downloaded to the /home/{hostusername}/Downloads. By default the {hostusername} is set to `viadmin`, make sure to change this value in the inputs file if you are using a different host username.
- Ensure that the [default environmental variables](./scripts/inputs/vars.env.sh) align with the cluster essentials version you plan to install.


### Install all items in taphostprep-1.sh to setup/configure linux environment
- Ensure that the [default environmental variables](./scripts/inputs/vars.env.sh) are verified before proceeding.
- when you execute the commands below you will be prompted to select yes to install several different packages, install all of them
- if you prefer to install all packages without being prompted for input, you can add the "-u" flag, but its good to go through the interactive mode at least the first time so you can better understand what the script does.
```sh
# If you are using a custom hostusername, you should ensure the {hostusername} variable set in your environment and in the vars.env.sh file before proceeding
# The following statement sets the {hostusername} variable to whatever it is already set to, if it has already been set. If the hostusername variable is not already set, it sets it to the value that is to the right of the ":-" characters, which is "viadmin"
export hostusername="${hostusername:-viadmin}"
# source the vars files to ensure they are available in your env
source "/home/${hostusername}/ovathetap/scripts/inputs/vars.env.sh"
# source the secrets files to ensure they are available in your env. Note that since we sourced the vars file above, we can start using project variables to simplify and clarify ongoing commands
source "/${ovathetap_inputs}/secrets.env.sh"
# make the taphostprep-1.sh script executable
sudo chmod +x /${ovathetap_scripts}/compound/taphostprep-1.sh
# execute the taphostprep-1.sh file. Optionally append "-u" to install all packages in non-interactive mode
sudo /tmp/taphostprep-1.sh # "-u"
```
- **IMPORTANT:** After the script completes, enter the following commands to enable sudoless docker calls. This is not just for user experience, it is required for subsequent steps to complete successfully.
```sh
sudo groupadd docker -f
sudo usermod -aG docker ${hostusername}
newgrp docker
```
- **IMPORTANT:** Reboot the host after the script completes
- After rebooting your host, verify you can execute docker commands without sudo by executing the command `docker run hello-world`

### Install CA Cert in Firefox to trust local sites

- Open firefox, navigate to settings and in the settings search window, search for "certificates"
- Select "View Certificates"
- Select "Import"
- Right click on a blank area of the file selector window and select the option to show hidden files
- Navigate to the /home/viadmin/.pki/myca/ directory and select the myca.pem file and click open to import the certificate
  - in the line above, "viadmin" is the default user account, if you have configured a nondefault username, use that value
- Select the options to Trust this CA for websites and email addresses and click ok to finish importing the certificate
- Close firefox settings

### Deploy Minikube Cluster
```sh
export hostusername="${hostusername:-viadmin}"
# source the vars files again since you should have rebooted after running taphostprep-1.sh
source "/home/${hostusername}/ovathetap/scripts/inputs/vars.env.sh"
# source the secrets files to ensure they are available in your env. Note that since we sourced the vars file above, we can start using project variables to simplify and clarify ongoing commands
source "/${ovathetap_inputs}/secrets.env.sh"
# Start Minikube
minikube start --kubernetes-version="${kubernetes_version}" --memory="${minikube_memory}" --cpus="${minikube_cpus}" --driver=docker --embed-certs --insecure-registry=0.0.0.0/0
# Gather minikube IP
echo "the minikube ip is: $(minikube ip)"
export minikubeip=$(minikube ip)
```

### Complete dnsmasq configuration
```sh
## Configure dnsmasq to resolve every request to *.tanzu.demo to the minikube IP
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.old
sudo echo "address=/tanzu.demo/${minikubeip}" | tee /etc/dnsmasq.conf
sudo systemctl restart dnsmasq
echo "dnsmasq configuration complete"
```

### Install Harbor
```sh
# REQUIRED: hydrate harborvalues file with docker_proxy_cache value if on a vmware internal network, if there is no {docker_proxy_cache} value, this simply makes the required copy of the harborvalues template in the correct location
envsubst < "${ovathetap_assets}/harborvalues.yaml.template" > "${ovathetap_assets}/harborvalues.yaml"
## Install Harbor
# Login to docker to assist with docker hub rate limiting
docker login -u "${docker_account_username}" -p "${docker_account_password}"
# Add the harbor repo to helm
helm repo add harbor https://helm.goharbor.io
# create namespace for harbor
kubectl create ns harbor
# install harbor
helm install harbor harbor/harbor -f "/${ovathetap_assets}/harborvalues.yaml" -n harbor
```
- **IMPORTANT:** It may take several minutes before the harbor deployment completes. Please ensure the harbor deployment is fully running before proceeding with the following verification steps:
  - enter the command `watch kubectl get deployments -n harbor` and wait for all of the deployments to be ready before proceeding
  - Open a tab in firefox and navigate to the url `http://192.168.49.2:30002` and verify the harbor login page is displayed
  - Login to the harbor web interface with the username `admin` and password `Harbor12345`
  - Verify you can also login from your terminal with the command `docker login 192.168.49.2:30002` - enter the username `admin` and password `Harbor12345` when prompted.
  - If any of these steps do not work, wait a few minutes and try again. Ensure these verification steps work before proceeding. 


### Install Tanzu CLI
```sh
## Install Tanzu CLI
cd "/${home_dir}/Downloads"
# create a directory to unzip the tanzu CLI files to
mkdir "/${tanzu_cli_dir}"
# unzip the file and install Tanzu CLI
tar -xvf "${tanzu_cli_bundle_filename}" -C "/${tanzu_cli_dir}"
export TANZU_CLI_NO_INIT=true
cd "/${tanzu_cli_dir}" 
export VERSION=${tanzu_cli_bundle_filename}
sudo install "cli/core/$VERSION/tanzu-core-linux_amd64" /usr/local/bin/tanzu
tanzu plugin install --local cli all
```

### Install Tanzu Cluster Essentials
```sh
## Install Cluster Essentials
cd "/${home_dir}/Downloads" 
# create a directory to unzip the tap installer files to
mkdir "/${cluster_essentials_dir}" 
# unzip the file and install cluster essentials
tar -xvf "${cluster_essentials_bundle_filename}" -C "/${cluster_essentials_dir}" 
kubectl create namespace kapp-controller
kubectl create secret generic kapp-controller-config \
   --namespace kapp-controller \
   --from-file caCerts=/home/viadmin/.pki/myca/myca.pem
export INSTALL_BUNDLE="${cluster_essentials_bundle_url}"
export INSTALL_REGISTRY_HOSTNAME="${tanzunet_hostname}"
export INSTALL_REGISTRY_USERNAME="${tanzunet_username}"
export INSTALL_REGISTRY_PASSWORD="${tanzunet_password}"
cd "/${cluster_essentials_dir}"
./install.sh --yes
# add carvel apps to path
cp "/${home_dir}/tanzu-cluster-essentials/kapp" /usr/local/bin/kapp
cp "/${home_dir}/tanzu-cluster-essentials/imgpkg" /usr/local/bin/imgpkg
cp "/${home_dir}/tanzu-cluster-essentials/kbld" /usr/local/bin/kbld
cp "/${home_dir}/tanzu-cluster-essentials/ytt" /usr/local/bin/ytt
```

### Relocate TAP images to the local Harbor registry
```sh
## Relocate TAP Images to your install registry
export INSTALL_REGISTRY_USERNAME=admin
export INSTALL_REGISTRY_PASSWORD=Harbor12345
export INSTALL_REGISTRY_HOSTNAME=192.168.49.2:30002
export TAP_VERSION="${tap_version}"
export INSTALL_REPO="${tap_install_repo}"
docker login $INSTALL_REGISTRY_HOSTNAME -u $INSTALL_REGISTRY_USERNAME -p $INSTALL_REGISTRY_PASSWORD
docker login "${tanzunet_hostname}" -u "${tanzunet_username}" -p "${tanzunet_password}"
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages
```

### Install TAP
```sh
## Prepare and inject local ca cert into ca_cert_data key in tap-values.yaml file
myca_path="${home_dir}/.pki/myca"
sed 's/^/    /' "/${myca_path}/myca.pem" > "/${script_tmp_dir}/myca-indented.pem"
sed "/ca_cert_data/ r /${script_tmp_dir}/myca-indented.pem" "/${ovathetap_assets}/tap-values.yaml.template" > "/${ovathetap_assets}/tap-values.yaml"
rm "/${script_tmp_dir}/myca-indented.pem"
## Install TAP
export INSTALL_REGISTRY_USERNAME=admin
export INSTALL_REGISTRY_PASSWORD=Harbor12345
export INSTALL_REGISTRY_HOSTNAME=192.168.49.2:31642
export TAP_VERSION="${tap_version}"
export INSTALL_REPO="${tap_install_repo}"
docker login $INSTALL_REGISTRY_HOSTNAME -u $INSTALL_REGISTRY_USERNAME -p $INSTALL_REGISTRY_PASSWORD
kubectl create ns tap-install
tanzu secret registry add tap-registry \
  --username ${INSTALL_REGISTRY_USERNAME} --password ${INSTALL_REGISTRY_PASSWORD} \
  --server ${INSTALL_REGISTRY_HOSTNAME} \
  --export-to-all-namespaces --yes --namespace tap-install
tanzu package repository add tanzu-tap-repository \
  --url ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages:$TAP_VERSION \
  --namespace tap-install
# TODO: I need to add some step here to automate waiting until reconciliation is complete before proceeding
- The Tanzu Package Repository should reconcile before proceeding, before you press enter to continue, please manually verify reconcilliation has completed
# Install profile
tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION --values-file "/${ovathetap_assets}/tap-values.yaml" -n tap-install
# Install Full Dependencies Package
## Get buildservice version number
tanzu package available list buildservice.tanzu.vmware.com --namespace tap-install
export BSVersion=$(tanzu package available list buildservice.tanzu.vmware.com --namespace tap-install | awk '{print $2}' | tail -n 1)
## Relocate full dependencies packages to your install repo
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/full-tbs-deps-package-repo:$BSVersion \
  --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tbs-full-deps
## Add the full dependencies package
tanzu package repository add tbs-full-deps-repository \
  --url ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tbs-full-deps:$BSVersion \
  --namespace tap-install
```

<!-- I dont know if we need minikube tunnel so testing without it this round. 
### Start Minikube tunnel

- `minikube tunnel`
- it may ask you to enter your password
- the process will take over the terminal session, so you will need to open a new terminal window to continue, leave the minikube tunnel terminal session open -->



<!-- ### Install Cert-Manager

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml
``` -->

<!-- ### Create a kubernetes secret with your CA certificates

```sh
kubectl create secret tls my-ca-secret --key /home/viadmin/.pki/myca/myca.key --cert /home/viadmin/.pki/myca/myca.pem -n cert-manager
``` -->

<!-- ### Create a cert-manager ClusterIssuer using your CA secret

- create a file ca-issuer.yaml with the following text:
```sh
cat << EOF > ca-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  ca:
    secretName: my-ca-secret
EOF
# Create the ClusterIssuer with the following command
kubectl apply -f ca-issuer.yaml
# Verify the cluster issuer was created and is ready with the following command:
kubectl get ClusterIssuer
```


TODO: Modify the learningcenter-portal ingress object to get cert from cert-manager
- need to add annotations and tls sections
- file saved to v4 branch in scripts/assets/tap/1_3/test_v3/learningcenter-portal-ingress.yaml

 this should already be addressed in the initial install steps, once verified, delete this commented step
#### Setup Ingress for tap-gui

tanzu package installed update tap -p tap.tanzu.vmware.com -v $TAP_VERSION  --values-file tap-values.yaml -n tap-install -->


