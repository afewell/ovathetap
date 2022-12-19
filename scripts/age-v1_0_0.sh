#!/bin/bash
## Injected vars
script_tmp_dir="${script_tmp_dir}"
home_dir="${home_dir}"

cd "/${script_tmp_dir}" || return
curl -Lo age.tar.gz "https://github.com/FiloSottile/age/releases/latest/download/age-v1.0.0-linux-amd64.tar.gz"
tar xf age.tar.gz
mv age/age /usr/local/bin
mv age/age-keygen /usr/local/bin
rm -rf age.tar.gz
rm -rf age
cd /${home_dir}
## age usage example
# # base64 encode file before encrypting
# cat raw_source_file.abc | base64 > source_file.abc
# # encrypt source_file.abc - user will be prompted for passphrase
# age -e -p -o encrypted_source_file.abc.age source_file.abc
# # decrypt source_file.abc - user will be prompted for passphrase
# age -d -o decrypted_source_file.abc encrypted_source_file.abc.age
# # base64 decode after decrypting
# cat decrypted_source_file.abc | base64 -d > raw_source_file.abc