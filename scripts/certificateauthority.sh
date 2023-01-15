#!/bin/bash
## script vars
hostusername="${hostusername:-viadmin}"
echo "${hostusername}"
home_dir="${home_dir:-~}"
echo "home_dir is: ${home_dir}"
ovathetap_assets="${ovathetap_assets}"
echo "ovathetap_assets is: ${ovathetap_assets}"



# Create Certificate Authority Per Ubuntu Docs https://ubuntu.com/server/docs/security-certificates 
# Ubuntu Configuration is Modified to match harbor docs: https://goharbor.io/docs/2.6.0/install-config/configure-https/
# The official openssl book was also referenced, and used as the source for the /assets/openssl.conf file
## First, create the directories to hold the CA certificate and related files:
mkdir -p /etc/ssl/CA
mkdir -p /etc/ssl/newcerts
## setup openssl.cnf file
mv /etc/ssl/openssl.cnf  /etc/ssl/openssl.cnf.old
cp /${ovathetap_assets}/openssl.cnf /etc/ssl/openssl.cnf
chown root:root /etc/ssl/openssl.cnf
## The CA needs a few additional files to operate, one to keep track of the last serial number used by the CA, each certificate must have a unique serial number, and another file to record which certificates have been issued:
sh -c "echo '01' > /etc/ssl/CA/serial"
touch /etc/ssl/CA/index.txt
## Create Private Key for CA
openssl genrsa -out /etc/ssl/CA/myca.key 4096
## Create Private Key for Harbor server certificate
openssl genrsa -out "/etc/ssl/CA/harbor.tanzu.demo.key" 4096
## Create CA Cert
openssl req -x509 -extensions v3_ca -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Washington/L=Seattle/O=VMware/OU=mamburger/CN=tanzu.demo" \
 -key "/etc/ssl/CA/myca.key" \
 -out "/etc/ssl/CA/myca.crt"
## Make a copy of the ca cert as a .pem file - the source is already in pem format, but some tools require the .pem extension
openssl x509 -outform pem -in "/etc/ssl/CA/myca.crt" -out "/etc/ssl/CA/myca.pem"
## Now install the root certificate and key:
cp "/etc/ssl/CA/myca.key" "/etc/ssl/private/cakey.pem"
cp "/etc/ssl/CA/myca.pem" "/etc/ssl/certs/cacert.pem"
## Copy the openssl.conf file into the /etc/ssl directory
cp "${ovathetap_assets}/openssl.conf" "/etc/ssl/openssl.conf"
## Create Certificate Signing Request for Harbor server
openssl req -sha512 -new \
    -subj "/C=CN/ST=Washington/L=Seattle/O=VMware/OU=mamburger/CN=harbor.tanzu.demo" \
    -key "/etc/ssl/CA/harbor.tanzu.demo.key" \
    -out "/etc/ssl/CA/harbor.tanzu.demo.csr"
## Generate an x509 v3 extension file for Harbor server
cat > "/etc/ssl/CA/v3.ext" <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=harbor.tanzu.demo
DNS.2=tanzu.demo
DNS.3=harbor
EOF
## Create Harbor server certificate
openssl x509 -req -sha512 -days 3650 \
    -extfile "/etc/ssl/CA/v3.ext" \
    -CA "/etc/ssl/CA/myca.crt" -CAkey "/etc/ssl/CA/myca.key" -CAcreateserial \
    -in "/etc/ssl/CA/harbor.tanzu.demo.csr" \
    -out "/etc/ssl/CA/harbor.tanzu.demo.crt"
## Make a copy of the harbor server cert as a pem file
openssl x509 -outform pem -in "/etc/ssl/CA/harbor.tanzu.demo.crt" -out "/etc/ssl/CA/harbor.tanzu.demo.pem"
## Convert harbor.tanzu.demo.crt to harbor.tanzu.demo.cert, for use by Docker
openssl x509 -inform PEM -in "/etc/ssl/CA/harbor.tanzu.demo.crt" -out "/etc/ssl/CA/harbor.tanzu.demo.cert"
## Copy the generated files into the docker certs directory
mkdir -p "/etc/docker/certs.d/tanzu.demo"
mkdir -p "/etc/docker/certs.d/harbor.tanzu.demo"
cp "/etc/ssl/CA/myca.crt" "/etc/docker/certs.d/tanzu.demo/ca.crt"
cp "/etc/ssl/CA/myca.crt" "/etc/docker/certs.d/harbor.tanzu.demo/ca.crt"
cp "/etc/ssl/CA/harbor.tanzu.demo.cert" "/etc/docker/certs.d/harbor.tanzu.demo/harbor.tanzu.demo.cert"
## Also copy the certs into a directory that includes the port number per harbor docs
mkdir -p "/etc/docker/certs.d/harbor.tanzu.demo:${minikube_harbor_port}"
cp "/etc/ssl/CA/myca.crt" "/etc/docker/certs.d/harbor.tanzu.demo:${minikube_harbor_port}/ca.crt"
cp "/etc/ssl/CA/harbor.tanzu.demo.cert" "/etc/docker/certs.d/harbor.tanzu.demo:${minikube_harbor_port}/harbor.tanzu.demo.cert"
## Set {hostusername} as owner of cert files
chown -R "${hostusername}:docker" "/etc/docker/certs.d/tanzu.demo/"
chown -R "${hostusername}:docker" "/etc/docker/certs.d/harbor.tanzu.demo/"
chown -R "${hostusername}:${hostusername}" "/${home_dir}/.pki/"
## Copy certs to minikube
mkdir -p "/${home_dir}/.minikube/certs/"
cp "/etc/ssl/CA/myca.pem" "/${home_dir}/.minikube/certs/myca.pem"
cp "/etc/ssl/CA/myca.crt" "/${home_dir}/.minikube/certs/myca.crt"
cp "/etc/ssl/CA/harbor.tanzu.demo.cert" "/${home_dir}/.minikube/certs/harbor.tanzu.demo.cert"
chown -R "${hostusername}:docker" "/${home_dir}/.minikube/"
## Install root CA cert in ubuntu trust store so localhost trusts CA
apt install -y ca-certificates
cp "/etc/ssl/CA/harbor.tanzu.demo.crt" /etc/ssl/certs
cp "/etc/ssl/CA/harbor.tanzu.demo.key" /etc/ssl/private
cp "/etc/ssl/CA/myca.pem" /usr/local/share/ca-certificates
update-ca-certificates