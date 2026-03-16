#!/bin/bash

set -e 

# Backup Minecraft Bedrock world files to S3
backup_dir="opt/minecraft/backups/"
backup_file="bedrock_world_backup_$(date +%Y%m%d%H%M%S).zip"
target_s3_path="s3://mc-server-ap-southeast-1-config-files-dev/bedrock/backup/"
working_dir="/opt/minecraft/server/worlds/'Bedrock level'/"

# shutdown the Bedrock server before backup
sudo systemctl stop bedrock.service

# create backup files from the world files
cd $working_dir
sudo zip -r $backup_dir/$backup_file ./*

# Upload the backup file to S3
sudo aws s3 cp $backup_dir/$backup_file $target_s3_path

#start the Bedrock server after backup
sudo systemctl start bedrock.service

