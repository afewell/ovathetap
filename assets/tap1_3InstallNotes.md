# OvaTheTap
The purpose of this document is to create a complete Full Profile installation for Tanzu Application Platform on a single VM.

The project is currently focused on a single environment topology, using a single, minimal ubuntu desktop VM to install kubernetes and TAP on a single host. The instructions and assets provided here should work on an ubuntu host with sufficient resources and performance, regardless of whether it is on bare metal or any virtualization platform, but the user may need to adjust some values for different environments.

# TAP 1.3 Single-node Lab Install Flow

## References:
#### [1] https://docs-staging.vmware.com/en/draft/VMware-Tanzu-Application-Platform/1.3
#### [2] https://tanzu.vmware.com/developer/guides/cert-manager-gs/
#### [3] https://tanzu.vmware.com/developer/guides/tanzu-application-platform-local-devloper-install/
#### [4] https://tanzu.vmware.com/developer/guides/harbor-gs/#set-up-dns
#### [5] https://github.com/afewell/scripts/
#### [6] https://tanzu.vmware.com/developer/blog/securely-connect-with-your-local-kubernetes-environment/
#### [7] https://thesecmaster.com/how-to-set-up-a-certificate-authority-on-ubuntu-using-openssl/
#### [8] https://computingforgeeks.com/install-and-configure-dnsmasq-on-ubuntu/
#### [9] https://goharbor.io/docs/2.6.0/install-config/configure-https/

## Linux Installation and Setup
### Provision an Ubuntu host

- In my initial tests I am using vCloud director to provision a VM (Running on vCenter) with the following specs:
  - CPU's: 16 single core CPU's
  - Memory: 64GB
  - Storage: 200GB HDD
  - OS: Ubuntu 20.04 Desktop (Minimal)
- After provisioning the host I just went through the standard installation wizard with standard/minimum options defined
- At this point I save a copy/template in my virtualization manager so when I need to provision a new VM I can load one up without needing to redo basic installation or maintain some other script to automate it
- The demo environment uses the default username viadmin. Note that if you want to use a different username in your ubuntu host, please follow the instructions wherever prompted in the instructions below to ensure your preferred linux host username is used. 


- If you are using vCloud director and want to configure the same as the test environment:
  - 
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

- `sudo netplan apply`

**Note:** It is a good practice to save your base vm or vapp template at this point.

### Install all items in taphostprep-1.sh
- **IMPORTANT** before you execute the commands below, note they will be configured for the default host username `viadmin`, if you would like this script to use a different host username, you must update the value in the /scripts/inputs/vars-1.env.sh file
- when you execute the commands below you will be prompted to select yes to install several different packages, install all of them
```sh
wget -O /tmp/taphostprep-1.sh https://raw.githubusercontent.com/afewell/ovathetap/main/scripts/compound/taphostprep-1.sh
sudo chmod +x /tmp/taphostprep-1.sh 
sudo /tmp/taphostprep-1.sh 
```
- **IMPORTANT:** Reboot the host after the script completes to ensure sudoless docker permissions are applied, which is REQUIRED for the following steps to complete successfully. 
  - I have tried multiple methods to apply permissions without reboot including `newgrp`, login/logout, and several other methods and could not get anything to work with perfect consistency other than reboot. 
- After rebooting your host, verify you can execute docker commands without sudo by executing the command `docker run hello-world`

### Install CA Cert in Firefox to trust local sites

- Open firefox, navigate to settings and in the settings search window, search for "certificates"
- Select "View Certificates"
- Select "Import"
- Right click on a blank area of the file selector window and select the option to show hidden files
- Navigate to the /home/viadmin/.pki/ca/ directory and select the ca.pem file and click open to import the certificate
  - in the line above, "viadmin" is the default user account, if you have configured a nondefault username, use that value
- Select the options to Trust this CA for websites and email addresses and click ok to finish importing the certificate
- Close firefox settings

### Launch Minikube and Configure dnsmasq
- from a terminal, execute the [taphostprep-2.sh script](./scripts/compound/taphostprep-2.sh) to launch minikube and configure dnsmasq. 
`sudo /home/viadmin/ovathetap/scripts/compound/taphostprep-2.sh`



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
``` -->

<!-- I did not install harbor in test 6, leaving this text commented for reference
### Install Harbor

- `docker login` before proceeding as its on docker registry so you may exceed download limit if not logged in

```sh
# Gather the harbors.yml file
wget -O harborvalues.yaml https://raw.githubusercontent.com/afewell/scripts/main/assets/tap/1_3/test_v3/resolv.conf
# Add the harbor repo to helm
helm repo add harbor https://helm.goharbor.io
# create namespace for harbor
kubectl create ns harbor
# install harbor
helm install harbor harbor/harbor -f harborvalues.yaml -n harbor
``` -->

### Install TAP

#### Download & Install Tanzu CLI Bundle

- go to https://network.tanzu.vmware.com/products/tanzu-application-platform
- login
- download the tanzu CLI bundle for your OS
```sh
# from your terminal, navigate to the directory where you downloaded the file
cd ~/Downloads
# create a directory to unzip the tanzu CLI files to
mkdir ~/tanzu
# unzip the file and install Tanzu CLI
tar -xvf tanzu-framework-linux-amd64.tar -C ~/tanzu
export TANZU_CLI_NO_INIT=true
cd ~/tanzu
export VERSION=v0.25.0
sudo install cli/core/$VERSION/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu plugin install --local cli all
```

#### Download & Install Cluster Essentials

- go to https://network.tanzu.vmware.com/products/tanzu-cluster-essentials/
- login
- download the cluster essentials bundle for your OS
```sh
# from your terminal, navigate to the directory where you downloaded the file
cd ~/Downloads
# create a directory to unzip the tap installer files to
mkdir ~/tanzu-cluster-essentials
# unzip the file and install cluster essentials
tar -xvf tanzu-cluster-essentials-linux-amd64-1.3.0.tgz -C ~/tanzu-cluster-essentials
kubectl create namespace kapp-controller
kubectl create secret generic kapp-controller-config \
   --namespace kapp-controller \
   --from-file caCerts=/home/viadmin/.pki/myca/myca.pem
export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:54bf611711923dccd7c7f10603c846782b90644d48f1cb570b43a082d18e23b9
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME=user@email.com
export INSTALL_REGISTRY_PASSWORD=$PASSWORD
cd $HOME/tanzu-cluster-essentials
./install.sh --yes
``` 

##### add imgpkg and kapp to path

```sh
sudo cp $HOME/tanzu-cluster-essentials/kapp /usr/local/bin/kapp
sudo cp $HOME/tanzu-cluster-essentials/imgpkg /usr/local/bin/imgpkg
```

### Relocate TAP Images to your install registry

```sh
export INSTALL_REGISTRY_USERNAME=admin
export INSTALL_REGISTRY_PASSWORD=Harbor12345
export INSTALL_REGISTRY_HOSTNAME=192.168.49.2:31642
export TAP_VERSION=1.3.0
export INSTALL_REPO=tap
docker login $INSTALL_REGISTRY_HOSTNAME
# Enter login info
docker login registry.tanzu.vmware.com
# Enter login info
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages
kubectl create ns tap-install
tanzu secret registry add tap-registry \
  --username ${INSTALL_REGISTRY_USERNAME} --password ${INSTALL_REGISTRY_PASSWORD} \
  --server ${INSTALL_REGISTRY_HOSTNAME} \
  --export-to-all-namespaces --yes --namespace tap-install
tanzu package repository add tanzu-tap-repository \
  --url ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages:$TAP_VERSION \
  --namespace tap-install
# manual verification step:
tanzu package repository get tanzu-tap-repository -n tap-install
# manual verification step:
tanzu package available list -n tap-install
# manual verification step:
tanzu package available list tap.tanzu.vmware.com -n tap-install
# Create tap profile manually - in next revision update to download the customized file
code tap-values.yaml
# Install profile
tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION --values-file tap-values.yaml -n tap-install
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

#### Modify the learningcenter-portal ingress object to get cert from cert-manager
- need to add annotations and tls sections
- file saved to v4 branch in scripts/assets/tap/1_3/test_v3/learningcenter-portal-ingress.yaml

#### Setup Ingress for tap-gui

tanzu package installed update tap -p tap.tanzu.vmware.com -v $TAP_VERSION  --values-file tap-values.yaml -n tap-install


