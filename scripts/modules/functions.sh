#!/bin/bash

# func_msg_block echos a provided message in a block of hashtags and tees it to the install log
# Required Input ${1}: Message you want displayed
# Stub: func_msg_block "${1}"
func_msg_block () {
    message="${1}"
    echo "##################################################" | tee -a /tmp/taphostprep.log
    echo "${message}" | tee -a /tmp/taphostprep.log
    echo "##################################################" | tee -a /tmp/taphostprep.log
}

# func_github_file_download downloads the specified filename or path/filename from the afewell/ovathetap repo and places it in /tmp
# Required input ${1}: filename or path/filename for the file to download relative to the root of the ovathetap repo
# Optional Input ${2}: local path to save the file at. Default is "./" which will save the file in the directory where the script is executed
# Stub: func_github_file_download "${1}" "${2:-./}"
func_github_file_download () {
    dl_pathfilename=${1}
    # the following if statement checks if dl_pathfilename has a / and if it does, it strips all text up to and including the last / and sets the result as ${filename}
    if [[ ${dl_pathfilename} == *"/"* ]]; 
    then
        filename=${dl_pathfilename##*/}
    else
        filename=${dl_pathfilename}
    fi
    save_file_path="${2:-./}"
    pre_install_msg="# Downloading ${filename} to ${save_file_path}${filename} "
    func_msg_block "${pre_install_msg}"
    # the raw_git_url must not have a trailing /
    raw_git_url="https://raw.githubusercontent.com/afewell/ovathetap/main"
    wget "${raw_git_url}/${dl_pathfilename}" -O "${save_file_path}${filename}" | tee -a /tmp/taphostprep.log
    post_install_msg="# Finished Downloading: ${filename} to ${save_file_path}${filename}"
    func_msg_block "${post_install_msg}"
}

# func_apt_install updates apt and then executes apt install ${1} -y
# if a more complicates apt install syntax is required, use func_install_script
# Required input ${1}: name of apt package as used in the command `apt-get install <apt package> -y`
# Stub: func_apt_install "${1}"
func_apt_install () {
    apt_package="${1}"
    pre_install_msg="# Installing: ${apt_package} "
    func_msg_block "${pre_install_msg}" 
    apt-get update | tee -a /tmp/taphostprep.log
    apt install "${apt_package}" -y | tee -a /tmp/taphostprep.log
    post_install_msg="# Finished Installing: ${1} "
    func_msg_block "${post_install_msg}"
}

# func_install_script downloads an install script from ${script_dir_url}/${1} and sources it for execution from this env
# Required Input 1: name of script file - must include path/filename as appended to script directory url
# Stub: func_install_script "<script filename>"
func_install_script () {
    script_filename=${1}
    pre_install_msg="# Installing: ${script_filename} "
    func_msg_block "${pre_install_msg}"
    func_github_file_download "scripts/${script_filename}" "/tmp/"
    chmod +x "/tmp/${script_filename}" | tee -a /tmp/taphostprep.log
    source "/tmp/${script_filename}" | tee -a /tmp/taphostprep.log
    rm "/tmp/${script_filename}" | tee -a /tmp/taphostprep.log
    post_install_msg="# Finished Installing: ${script_filename} "
    func_msg_block "${post_install_msg}"
}
# func_clone_repo clones the specified repo
# Calling env must have host username set as ${user} envar
# Required Input 1: git repositry url, as used in the command `git clone <git url>`
# Required Input 2: host username. Used to identify the directory to clone the repo from /home/<username>
# Stub: func_clone_repo "$1" "$2"
func_clone_repo () {
    giturl="${1}"
    hostusername="${2}"
    pre_install_msg="# Cloning Repository: ${giturl} "
    func_msg_block "${pre_install_msg}"
    cd "/home/${hostusername}" || return  | tee -a /tmp/taphostprep.log
    git clone "${giturl}" | tee -a /tmp/taphostprep.log
    reponame=${giturl##*/}
    chown -R ${hostusername}:${hostusername} "/home/${hostusername}/${reponame}" | tee -a /tmp/taphostprep.log
    post_install_msg="# Finished Cloning Repository: ${giturl} "
    func_msg_block "${post_install_msg}"
}

