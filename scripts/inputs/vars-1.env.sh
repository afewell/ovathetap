#!/bin/bash
# This file is sourced to provide envars to the taphostprep process
# DO NOT include leading or trailing forward slashes in variables, they should be added as needed by functions or in the script(s)
## This document is divided into 2 sections:
### Section 1: things that are more likely to be changed when customized which should be ok to customize
### Section 2: things that are less likely to be customized which you probably shouldnt customize
### Note that only the default settings are tested in the default/reference environment


## Section 1: things that are more likely to be customized which should be ok to customize
# hostusername should be the linux username of the account the host should be prepped for. For example, the script will install and assign files to this user's home directory and ensure they have the permissions needed to complete the installation and subsequent exercises
export hostusername="viadmin"
# the kubernetes version defines both what k8s version the minikube cluster will run, and also the version of kubectl that will be installed
export kubernetes_version="1.23.10"
export tanzu_cli_version="v0.25.0"
export tap_version="1.3.0"
# tap_install_repo is used to populate the INSTALL_REPO var per the tap install docs. It is used to provide the namespace for saving tap files in the registry so tap install images would be saved at {registry}/{tap_install_repo}/{images}
export tap_install_repo="tap"
export tanzu_cli_bundle_filename="tanzu-framework-linux-amd64.tar"
export cluster_essentials_bundle_url="registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:54bf611711923dccd7c7f10603c846782b90644d48f1cb570b43a082d18e23b9"
export cluster_essentials_bundle_filename="tanzu-cluster-essentials-linux-amd64-1.3.0.tgz"
export tanzunet_hostname="registry.tanzu.vmware.com"



export minikube_memory="48g"
export minikube_cpus="12"

## Section 2: things that are less likely to be customized which you probably shouldnt customize
export home_dir="home/${hostusername}"
export ovathetap_home="${home_dir}/ovathetap"
export ovathetap_assets="${ovathetap_home}/assets"
export ovathetap_scripts="${ovathetap_home}/scripts"
export ovathetap_modules="${ovathetap_home}/modules"
export 
export raw_git_url="https://raw.githubusercontent.com/afewell/ovathetap/main"
export modules_path="scripts/modules"
export functions_filename="functions.sh"
export script_tmp_dir="tmp/taphostprep"
export inputs_path="scripts/inputs"
export envars_filename="vars-1.env.sh"
