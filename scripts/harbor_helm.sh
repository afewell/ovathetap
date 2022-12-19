#!/bin/bash

## Injected vars
docker_account_username="${docker_account_username}"
docker_account_password="${docker_account_password}"
ovathetap_assets="${ovathetap_assets}"
hostusername="${hostusername}"

# stub harborvalues file with docker_proxy_cache value if on vmware_int_net (a vmware internal network)
if [ "${vmware_int_net}" = "true" ]; then export docker_proxy_cache="harbor-repo.vmware.com/dockerhub-proxy-cache/"; fi
envsubst < "${ovathetap_assets}/harborvalues.template" > "${ovathetap_assets}/harborvalues.yaml"

## Install Harbor
# Login to docker to assist with docker hub rate limiting
docker login -u "${docker_account_username}" -p "${docker_account_password}"
# Add the harbor repo to helm
helm repo add harbor https://helm.goharbor.io
# create namespace for harbor
kubectl create ns harbor
# install harbor
helm install harbor harbor/harbor -f "/${ovathetap_assets}/harborvalues.yaml" -n harbor
chown ${hostusername}:${hostusername} "/${ovathetap_assets}/harborvalues.yaml"
read -t 5 -p "completing harbor deployment"
echo "Harbor desired state configuration applied - follow instructions to verify deployment"