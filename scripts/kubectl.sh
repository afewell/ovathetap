#!/bin/bash
## Inject vars used in this script 
kubernetes_version="${kubernetes_version}"
home_dir="${home_dir}"

## Install kubectl
cd /tmp
curl -LO "https://dl.k8s.io/release/v${kubernetes_version}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
cd "/${home_dir}" || return
## Configure kubernetes autocompletion
source <(kubectl completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubectl completion bash)" >> "/${home_dir}/.bashrc" # add autocomplete permanently to your bash shell.
## add k alias with persistence and autocompletion
alias k=kubectl
echo "alias k=kubectl" >> "/${home_dir}/.bashrc"
complete -o default -F __start_kubectl k
echo "complete -o default -F __start_kubectl k" >> "/${home_dir}/.bashrc"