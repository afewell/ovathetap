#!/bin/bash

## Injected vars
 home_dir="${home_dir}"
cluster_essentials_dir="${cluster_essentials_dir}"
cluster_essentials_bundle_filename="${cluster_essentials_bundle_filename}"
cluster_essentials_bundle_url="${cluster_essentials_bundle_url}"
tanzunet_hostname="${tanzunet_hostname}"
tanzunet_username="${tanzunet_username}"
tanzunet_password="${home_dir}"

## Install Cluster Essentials
cd "/${home_dir}/Downloads" || return
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
cd "/${cluster_essentials_dir}"  || return
./install.sh --yes
# add carvel apps to path
cp "/${home_dir}/tanzu-cluster-essentials/kapp" /usr/local/bin/kapp
cp "/${home_dir}/tanzu-cluster-essentials/imgpkg" /usr/local/bin/imgpkg
cp "/${home_dir}/tanzu-cluster-essentials/kbld" /usr/local/bin/kbld
cp "/${home_dir}/tanzu-cluster-essentials/ytt" /usr/local/bin/ytt