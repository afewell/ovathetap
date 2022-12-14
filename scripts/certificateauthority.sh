#!/bin/bash
## script vars
hostusername="${hostusername:-viadmin}"
echo "${hostusername}"
home_dir="${home_dir:-~}"
echo "${home_dir}"
ovathetap_assets="${ovathetap_assets}"
echo "${ovathetap_assets}"

## Create Private Key for CA
mkdir -p "/${home_dir}/.pki/myca"
openssl genrsa -out "/${home_dir}/.pki/myca/myca.key" 4096
## Create CA Cert
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Washington/L=Seattle/O=VMware/OU=mamburger/CN=tanzu.demo" \
 -key "/${home_dir}/.pki/myca/myca.key" \
 -out "/${home_dir}/.pki/myca/myca.pem"
## Set {hostusername} as owner of cert files
chown -R "${hostusername}:${hostusername}" "/${home_dir}/.pki/"
## Copy certs to minikube
mkdir -p "/${home_dir}/.minikube/certs/"
chown -R "${hostusername}:docker" "/${home_dir}/.minikube/"
cp "/${home_dir}/.pki/myca/myca.pem" "/${home_dir}/.minikube/certs/myca.pem"
## Install root CA cert in ubuntu trust store so localhost trusts CA
apt install -y ca-certificates
cp "/${home_dir}/.pki/myca/myca.pem" /usr/local/share/ca-certificates
ln -s "/${home_dir}/.pki/myca/myca.pem" /etc/ssl/certs/cacert.pem
update-ca-certificates