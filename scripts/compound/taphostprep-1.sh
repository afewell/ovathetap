#!/bin/bash

## This script can be called with an input variable ${1} of "-u" for unattended installation

## Script variables
### Inject envars from input file
hostusername="${hostusername:-viadmin}"
echo "hostusername: $(echo $hostusername)"
echo 'source "/home/${hostusername}/ovathetap/scripts/inputs/vars.env.sh"'
source "/home/${hostusername}/ovathetap/scripts/inputs/vars.env.sh"
echo "Here is the env:"
env
echo "The above line is end of the env output"
### Injected Vars that are used in this file:
 
### Inject Secret variables from input file 
# commented because no secrets needed in this file
# source "/home/${hostusername}/ovathetap/scripts/inputs/secrets.env.sh"

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
    echo "##################################################" | tee -a /tmp/taphostprep.log
    echo "# ${message}" | tee -a /tmp/taphostprep.log
    echo "##################################################" | tee -a /tmp/taphostprep.log
}

# func_apt_install updates apt and then executes apt install ${1} -y
# if a more complicates apt install syntax is required, use func_install_script
# Required input ${1}: name of apt package as used in the command `apt-get install <apt package> -y`
# Stub: func_apt_install "${1}"
function func_apt_install () {
    apt_package="${1}"
    func_msg_block "pre" "${apt_package}"
    apt-get update | tee -a /tmp/taphostprep.log
    apt install "${apt_package}" -y | tee -a /tmp/taphostprep.log
    func_msg_block "post" "${apt_package}"
}

# func_install_script downloads an install script from ${script_dir_url}/${1} and sources it for execution from this env
# Required Input 1: name of script file - must include path/filename as appended to script directory url
# Stub: func_install_script "<script filename>"
function func_install_script () {
    script_filename=${1}
    func_msg_block "pre" "${script_filename}"
    source "/${ovathetap_scripts}/${script_filename}" | tee -a /tmp/taphostprep.log
    post_install_msg="# Finished Installing: ${script_filename} "
    func_msg_block "post" "${script_filename}"
}

# Main
mkdir "/${script_tmp_dir}"
# Setup passwordless sudo
echo "${hostusername} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${hostusername}"

# The following line check to see if this script was called with the -u flag, which sets the {install_all} variable to y, which provides an unattended/noninteractive execution
if [ "${1}" = "-u" ]; then install_all=y; fi

if [ "${install_all}"  ]; then install=y; else read -p  "Refresh snap to prevent sporadic Ubuntu error? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    killall snap-store
    snap refresh
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install Open SSH Server to Allow Remote SSH Connections to this host? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "openssh-server"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install ntp? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "ntp"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install curl? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "curl"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install vim? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "vim"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install git? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "git"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install age? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "age-v1_0_0.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install Docker CE? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "dockerce.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install VS Code? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "vscode.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install JQ? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_apt_install "jq"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install minikube? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "minikube.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install kubectl? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "kubectl.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install helm? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "helm.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Install dnsmasq? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "dnsmasq.sh"
fi

if [ "${install_all}"  ]; then install=y; else read -p  "Setup private certificate authority? (y/n):" install; fi
if [ "$install" = "y" ] || [ "$install" = "Y" ]
then
    func_install_script "certificateauthority.sh"
fi



## The below command should be the last thing that executes

if [ -f /tmp/postactions.txt ]
then
    cat /tmp/postactions.txt
    rm /tmp/postactions.txt
fi
