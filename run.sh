#!/bin/bash

set -x

echo "beginning backup: $(date +"%Y-%m-%d %H:%M:%S")" | tee -a log.txt
./hosting_to_local.sh cvuuf_org.conf
echo "copied members to here: $(date +"%Y-%m-%d %H:%M:%S")" | tee -a log.txt
./hosting_to_local.sh cvuuf_mainwp.conf
echo "copied wordpress to here: $(date +"%Y-%m-%d %H:%M:%S")" | tee -a log.txt

# drive init --service-account-file <gsa_json_file_path> ~/gdrive
# https://github.com/odeke-em/drive
echo "before push: $(date +"%Y-%m-%d %H:%M:%S")" | tee -a log.txt
drive push --verbose --ignore-name-clashes --hidden --no-prompt --destination website-backups
echo "finished: $(date +"%Y-%m-%d %H:%M:%S")" | tee -a log.txt

