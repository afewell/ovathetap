#!/bin/bash

## This script can be called with an input variable ${1} of "-u" for unattended installation
# Check if -u flag is passed as first argument
if [ "$1" = "-u" ]; then
  install_all=y
fi

## Script variables
### Inject envars from input file
hostusername="${hostusername:-viadmin}"
script_tmp_dir=${script_tmp_dir:-tmp/taphostprep}
echo "hostusername: $(echo $hostusername)"
echo 'source "/home/${hostusername}/ovathetap/config/vars.env.sh"'
source "/home/${hostusername}/ovathetap/config/vars.env.sh"
echo "Here is the env command output:"
env
echo "The above line is end of the env output"
### Injected Vars that are used in this file:
 
### Inject Secret variables from input file 
# commented because no secrets needed in this file
# source "/home/${hostusername}/ovathetap/config/secrets.env.sh"

# Define an array of packages to install
packages=(
  "openssh-server"
  "ntp"
  "curl"
  "vim"
  "git"
  "jq"
  "age"
)

# Define an array of scripts to run
scripts=(
  "age-v1_0_0.sh"
  "dockerce.sh"
  "vscode.sh"
  "minikube.sh"
  "kubectl.sh"
  "helm.sh"
  "dnsmasq.sh"
  "certificateauthority.sh"
)

## Define Functions
# func_msg_block echos a provided message in a block of hashtags and tees it to the install log
# Required Input ${1}: can be one of:
##  "pre": will use default pre message, func call must include package name OR script filename as ${2}
##  "post": will use default post message, func call must include package name OR script filename as ${2}
##  any string other than "pre" or "post" will be treated as a custom message and displayed in place of a default message. 
# Optional Input ${2}: name of apt package or filename of install script. Only used if ${1} =  "pre" or "post"
# Stub: func_msg_block "${1}" "${2}"
func_msg_block () {
    case "$1" in
        "pre")
            # code to execute if $1 is equal to "pre"
            message="Installing: ${2} "
            ;;
        "post")
            # code to execute if $1 is equal to "post"
            message="Finished Installing: ${2} "
            ;;
        *)
            # code to execute if $1 is any other non-empty string
            message="${1}"
            ;;
    esac
    echo "##################################################" | tee -a /${script_tmp_dir}/taphostprep.log
    echo "# ${message}" | tee -a /${script_tmp_dir}/taphostprep.log
    echo "##################################################" | tee -a /${script_tmp_dir}/taphostprep.log
}

# func_apt_install updates apt and then executes apt install ${1} -y
# if a more complicates apt install syntax is required, use func_install_script
# Required input ${1}: name of apt package as used in the command `apt-get install <apt package> -y`
# Stub: func_apt_install "${1}"
function func_apt_install () {
    apt_package="${1}"
    if [ "$install_all" ] || [ "$install" = "y" ] || [ "$install" = "Y" ]; then
        func_msg_block "pre" "${apt_package}"
        apt-get update | tee -a /${script_tmp_dir}/taphostprep.log
        apt install "${apt_package}" -y | tee -a /${script_tmp_dir}/taphostprep.log
        func_msg_block "post" "${apt_package}"
    fi
}

# func_install_script downloads an install script from ${script_dir_url}/${1} and sources it for execution from this env
# Required Input 1: name of script file - must include path/filename as appended to script directory url
# Stub: func_install_script "<script filename>"
function func_install_script () {
    script_filename=${1}
    if [ "$install_all" ] || [ "$install" = "y" ] || [ "$install" = "Y" ]; then
        func_msg_block "pre" "${script_filename}"
        source "/${ovathetap_scripts}/${script_filename}" | tee -a /${script_tmp_dir}/taphostprep.log
        func_msg_block "post" "${script_filename}"
    fi
}

# Main
if [ ! -d /${script_tmp_dir} ]
then
    mkdir "/${script_tmp_dir}"
    chown "${hostusername}":"${hostusername}" "/${script_tmp_dir}"
fi

# Refresh snap to prevent sporadic Ubuntu error
killall snap-store
snap refresh

# Setup passwordless sudo
if [ "$install_all" ]; then
    install=y
else
    read -p "Configure host for passwordless sudo? (y/n):" install
fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]; then
    echo "${hostusername} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${hostusername}"
fi


# Install packages
for package in "${packages[@]}"; do
  if [ "$install_all" ]; then
    install=y
  else
    read -p "Install $package? (y/n):" install
  fi
  func_apt_install $package
done

# Run scripts
for script in "${scripts[@]}"; do
  if [ "$install_all" ]; then
    install=y
  else
    read -p "Run script $script? (y/n):" install
  fi
  func_install_script $script
done



## The below command should be the last thing that executes

if [ -f /${script_tmp_dir}/postactions.txt ]
then
    cat /${script_tmp_dir}/postactions.txt
    rm /${script_tmp_dir}/postactions.txt
fi
