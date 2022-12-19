#!/bin/bash

## Script variables
### Inject envars from input file
source "./scripts/inputs/vars-1.env.sh"
### Inject Secret variables from input file 
source "./scripts/inputs/secrets.env.sh"

## Import Functions
source "./scripts/modules/functions.sh"

# Main
mkdir ${script_tmp_dir}
## Install Tanzu CLI
source "/${ovathetap_scripts}/tanzu_cli.sh"

## Install Cluster Essentials
source "/${ovathetap_scripts}/tanzu_cluster_essentials.sh"

