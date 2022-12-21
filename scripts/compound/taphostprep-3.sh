#!/bin/bash

## Script variables
### Inject envars from input file
hostusername="${hostusername:-viadmin}"
source "/home/${hostusername}/ovathetap/scripts/inputs/vars.env.sh"
### Inject Secret variables from input file 
source "/home/${hostusername}/ovathetap/scripts/inputs/secrets.env.sh"

## Import Functions
source "/home/${hostusername}/ovathetap/scripts/modules/functions.sh"

# Main
mkdir "/${script_tmp_dir}"
## Install Tanzu CLI
source "/${ovathetap_scripts}/tanzu_cli.sh"

## Install Cluster Essentials
source "/${ovathetap_scripts}/cluster_essentials.sh"

