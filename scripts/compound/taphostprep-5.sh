#!/bin/bash

## Script variables
### Inject envars from input file
source "./scripts/inputs/vars-1.env.sh"
### Inject Secret variables from input file 
source "./scripts/inputs/secrets.env.sh"

## Import Functions
source "./scripts/modules/functions.sh"

# Main
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
read -p "The Tanzu Package Repository should reconcile before proceeding, before you press enter to continue, please open a new terminal window and follow the steps in the instructions to manually verify reconcilliation has completed - and then press enter in this window to continue the tap installation script"
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