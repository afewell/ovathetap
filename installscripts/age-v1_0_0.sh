#!/bin/bash

cd /tmp
curl -Lo age.tar.gz "https://github.com/FiloSottile/age/releases/latest/download/age-v1.0.0-linux-amd64.tar.gz"
tar xf age.tar.gz
mv age/age /usr/local/bin
mv age/age-keygen /usr/local/bin
rm -rf age.tar.gz
rm -rf age
cd /home/${user}