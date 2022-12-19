#!/bin/bash

## Script variables
### Inject envars from input file
hostusername="${hostusername:-viadmin}"
source "/home/${hostusername}/ovathetap/scripts/inputs/vars-1.env.sh"
### Inject Secret variables from input file 
source "/home/${hostusername}/ovathetap/scripts/inputs/secrets.env.sh"

## Import Functions
source "/home/${hostusername}/ovathetap/scripts/modules/functions.sh"

# Main
mkdir "/${script_tmp_dir}"
## Relocate TAP Images to your install registry
export INSTALL_REGISTRY_USERNAME=admin
export INSTALL_REGISTRY_PASSWORD=Harbor12345
export INSTALL_REGISTRY_HOSTNAME=192.168.49.2:31642
export TAP_VERSION="${tap_version}"
export INSTALL_REPO="${tap_install_repo}"
docker login $INSTALL_REGISTRY_HOSTNAME -u $INSTALL_REGISTRY_USERNAME -p $INSTALL_REGISTRY_PASSWORD
docker login "${tanzunet_hostname}" -u "${tanzunet_username}" -p "${tanzunet_password}"
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages