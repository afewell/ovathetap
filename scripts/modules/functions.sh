#!/bin/bash

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
        [-z "$1"])
            # code to execute if $1 is an empty string
            message="Error - no input provided"
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
func_apt_install () {
    apt_package="${1}"
    func_msg_block "pre" "${apt_package}"
    apt-get update | tee -a /tmp/taphostprep.log
    apt install "${apt_package}" -y | tee -a /tmp/taphostprep.log
    func_msg_block "post" "${apt_package}"
}
export -f func_apt_install

# func_install_script downloads an install script from ${script_dir_url}/${1} and sources it for execution from this env
# Required Input 1: name of script file - must include path/filename as appended to script directory url
# Stub: func_install_script "<script filename>"
func_install_script () {
    script_filename=${1}
    func_msg_block "pre" "${script_filename}"
    source "/${ovathetap_scripts}/${script_filename}" | tee -a /tmp/taphostprep.log
    post_install_msg="# Finished Installing: ${script_filename} "
    func_msg_block "post" "${script_filename}"
}
export -f func_install_script

# ## func_slasher is commented out because it became unused due to refactoring. At some point if remains unused should just delete it but for now I will leave it commented for reference
# # func_slasher accepts a string and appends both a leading and trailing forward slash to the string
# # Required Input ${1}: any string
# # Stub: func_slasher "${1}"
# func_slasher () {
#     string="${1}"
#     echo "${string}" | sed 's/.*/\/&\//'
# }

## func_github_file_download is commented out because it became unused due to refactoring. At some point if remains unused should just delete it but for now I will leave it commented for reference
# # func_github_file_download downloads the specified filename or path/filename from the afewell/ovathetap repo and places it in /tmp
# # Required input ${1}: filename or path/filename for the file to download relative to the root of the ovathetap repo
# # Optional Input ${2}: local path to save the file at. Default will save to calling location. IMPORTANT
# # Stub: func_github_file_download "${1}" "${2:-.}"
# func_github_file_download () {
#     dl_pathfilename=${1}
#     # the following if statement checks if dl_pathfilename has a / and if it does, it strips all text up to and including the last / and sets the result as ${filename}
#     if [[ ${dl_pathfilename} == *"/"* ]]; 
#     then
#         filename=${dl_pathfilename##*/}
#     else
#         filename=${dl_pathfilename}
#     fi
#     save_file_path="${2}"
#     # the following if statement checks if the save_file_path variable is populated, and if so, appends a leading and trailing forward slash. This supports project goal of consistent slash usage for user inputs, eg, no leading/trailing slashes for user inputs and vars
#     if [[ ${save_file_path} ]]; 
#     then
#         save_file_path=$(func_slasher "${save_file_path}")
#     fi
#     pre_install_msg="# Downloading ${filename} to ${save_file_path}${filename} "
#     func_msg_block "${pre_install_msg}"
#     wget "${raw_git_url}/${dl_pathfilename}" -O "${save_file_path}${filename}"
#     post_install_msg="# Finished Downloading: ${filename} to ${save_file_path}${filename}"
#     func_msg_block "${post_install_msg}"
# }


## func_clone_repo is commented out because it became unused due to refactoring. At some point if remains unused should just delete it but for now I will leave it commented for reference
# # func_clone_repo clones the specified repo
# # Calling env must have host username set as ${user} envar
# # Required Input 1: git repositry url, as used in the command `git clone <git url>`
# # Required Input 2: host username. Used to identify the directory to clone the repo from /home/<username>
# # Stub: func_clone_repo "$1" "$2"
# func_clone_repo () {
#     giturl="${1}"
#     hostusername="${2}"
#     pre_install_msg="# Cloning Repository: ${giturl} "
#     func_msg_block "${pre_install_msg}"
#     cd "/home/${hostusername}" || return  | tee -a /tmp/taphostprep.log
#     git clone "${giturl}" | tee -a /tmp/taphostprep.log
#     reponame=${giturl##*/}
#     chown -R ${hostusername}:${hostusername} "/home/${hostusername}/${reponame}" | tee -a /tmp/taphostprep.log
#     post_install_msg="# Finished Cloning Repository: ${giturl} "
#     func_msg_block "${post_install_msg}"
# }