#!/bin/bash

## Script variables
### Inject envars from input file
source "./scripts/inputs/vars-1.env.sh"
### Inject Secret variables from input file 
source "./scripts/inputs/secrets.env.sh"

## Import Functions
source "./scripts/modules/functions.sh"

# Main

## Start Minikube
minikube start --kubernetes-version="${kubernetes_version}" --memory="${minikube_memory}" --cpus="${minikube_cpus}" --embed-certs --insecure-registry=192.168.49.0/24
# the following line pauses script execution for 5 seconds to ensure minikube is fully loaded, it may not be necessary and if it is, its probably better in the future to use a different method to dynamically verify minikube readiness before proceeding
read -t 5 -p "minikube cluster deployed, pausing script for 5 seconds"
### Gather minikube IP
echo "the minikube ip is: $(minikube ip)"
export minikubeip=$(minikube ip)

## Configure dnsmasq to resolve every request to *.tanzu.demo to the minikube IP
mv /etc/dnsmasq.conf /etc/dnsmasq.old
echo "address=/tanzu.demo/${minikubeip}" | tee /etc/dnsmasq.conf
systemctl restart dnsmasq
echo "dnsmasq configuration complete"

## Install Harbor
source "/${ovathetap_scripts}"