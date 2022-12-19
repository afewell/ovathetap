#!/bin/bash

## Injected vars
home_dir=${home_dir}
tanzu_cli_dir=${tanzu_cli_dir}
tanzu_cli_bundle_filename=${tanzu_cli_bundle_filename}
tanzu_cli_bundle_filename=${tanzu_cli_bundle_filename}

## Install Tanzu CLI
cd "/${home_dir}/Downloads" || return
# create a directory to unzip the tanzu CLI files to
mkdir "/${tanzu_cli_dir}"
# unzip the file and install Tanzu CLI
tar -xvf "${tanzu_cli_bundle_filename}" -C "/${tanzu_cli_dir}"
export TANZU_CLI_NO_INIT=true
cd "/${tanzu_cli_dir}" || return
export VERSION=${tanzu_cli_bundle_filename}
sudo install "cli/core/$VERSION/tanzu-core-linux_amd64" /usr/local/bin/tanzu
tanzu plugin install --local cli all