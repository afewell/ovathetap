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

- `sudo netplan apply`

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

- Verify the [default environmental variables](./scripts/inputs/vars-1.env.sh), and modify if needed
- Make a copy of the secrets template with the command `cp ~/ovathetap/scripts/inputs/secrets.env.template ~/ovathetap/scripts/inputs/secrets.env.sh`
- Edit the copy of the secrets file and populate all listed variables
  - **Note:** You should never upload your populated secrets file to github. A gitignore file is included in the inputs directory to help prevent your secrets from being uploaded. 
  - You can access your secrets file at [~/ovathetap/scripts/inputs/secrets.env.sh](~/ovathetap/scripts/inputs/secrets.env.sh)
- **VMWARE EMPLOYEES:** IF your lab environment is on a vmware internal network, please include the line `export vmware_int_net="true"` in the vars-1.env.sh file. This sets up the docker_proxy_cache, which can help bypass the crippling docker hub rate limits, but it only works from vmware internal networks. 

### Download  Tanzu CLI Bundle

- go to https://network.tanzu.vmware.com/products/tanzu-application-platform
- login
- download the tanzu CLI bundle for linux
- **IMPORTANT** the tanzu CLI bundle must be downloaded to the /home/{hostusername}/Downloads. By default the {hostusername} is set to `viadmin`, make sure to change this value in the inputs file if you are using a different host username.


### Download & Install Cluster Essentials

- go to https://network.tanzu.vmware.com/products/tanzu-cluster-essentials/
- login
- download the cluster essentials bundle for linux
- **IMPORTANT** the tanzu CLI bundle must be downloaded to the /home/{hostusername}/Downloads. By default the {hostusername} is set to `viadmin`, make sure to change this value in the inputs file if you are using a different host username.


### Install all items in taphostprep-1.sh to setup/configure linux environment
- **IMPORTANT** before you execute the commands below, note they will be configured for the default host username `viadmin`, if you would like this script to use a different host username, you must update the value in the /scripts/inputs/vars-1.env.sh file
- when you execute the commands below you will be prompted to select yes to install several different packages, install all of them
```sh
wget -O /tmp/taphostprep-1.sh https://raw.githubusercontent.com/afewell/ovathetap/main/scripts/compound/taphostprep-1.sh
sudo chmod +x /tmp/taphostprep-1.sh 
sudo /tmp/taphostprep-1.sh 
```
- **IMPORTANT:** Reboot the host after the script completes to ensure sudoless docker permissions are applied, which is REQUIRED for the following steps to complete successfully. 
  - I have tried multiple methods to apply permissions without reboot including `newgrp`, login/logout, and several other methods and could not get anything to work with consistency other than reboot. 
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

### Execute taphostprep-2.sh to configure base kubernetes environment
- **IMPORTANT** before you execute the commands below, note they will be configured for the default host username `viadmin`, if you would like this script to use a different host username, you must update the value in the /scripts/inputs/vars-1.env.sh file
- from a terminal, execute the [taphostprep-2.sh script](./scripts/compound/taphostprep-2.sh) to launch minikube and configure dnsmasq. 
  - `sudo /home/viadmin/ovathetap/scripts/compound/taphostprep-2.sh`
- **IMPORTANT:** After the script completes, verify all harbor components are running before proceeding. This usually works very quickly, but can commonly be delayed due to docker hub rate limiting. This can sometimes cause harbor deployment to be delayed significantly. If you see your harbor containers arent downloading due to rate limiting, this will usually resolve eventually by itself, but it can take several hours. To avoid this, its best to have a paid docker account or use a docker caching server if one is available in your environment.
 - To verify your harbor installation is running: 
   - enter the command `kubectl get all -n harbor` and verify the state of components
   - TODO: add instructions to login to harbor web gui for additional verification



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

### Execute taphostprep-3.sh to install Tanzu Cli and Cluster Essentials

### Execute taphostprep-4.sh to transfer TAP images to the local harbor registry

### Execute taphostprep-5.sh to install TAP
- run the script, when prompted to verify tap reconciliation, open a NEW terminal and run the following commands:
  - tanzu package repository get tanzu-tap-repository -n tap-install
  - tanzu package available list -n tap-install
  - tanzu package available list tap.tanzu.vmware.com -n tap-install
- After verifying reconciliation has completed, return to the original 


TODO: Modify the learningcenter-portal ingress object to get cert from cert-manager
- need to add annotations and tls sections
- file saved to v4 branch in scripts/assets/tap/1_3/test_v3/learningcenter-portal-ingress.yaml

<!-- this should already be addressed in the initial install steps, once verified, delete this commented step
#### Setup Ingress for tap-gui

tanzu package installed update tap -p tap.tanzu.vmware.com -v $TAP_VERSION  --values-file tap-values.yaml -n tap-install -->


