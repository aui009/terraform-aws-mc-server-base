#!/bin/bash

set -e 

# Set environment variable for ssm parameter
ENV=$(sudo aws ssm get-parameter --name "MC-environment" --with-decryption --query Parameter.Value --output text)

# Backup Minecraft Bedrock world files to S3
backup_dir="/opt/minecraft/backups/"
backup_file="bedrock_world_backup_$(date +%Y%m%d%H%M%S).zip"
target_s3_path="s3://mc-server-ap-southeast-1-config-files-$ENV/bedrock/backup/"
working_dir="/opt/minecraft/server/worlds/Bedrock level/"

# shutdown the Bedrock server before backup
echo "$(date +'%Y-%m-%d %H:%M:%S'): Stopping Bedrock server for backup"
sudo systemctl stop bedrock.service

# create backup files from the world files
echo "$(date +'%Y-%m-%d %H:%M:%S'): Creating backup of Bedrock world files"
cd "$working_dir"
sudo zip -r $backup_dir$backup_file ./

echo "$(date +'%Y-%m-%d %H:%M:%S'): Backup created at $backup_dir$backup_file"
# Upload the backup file to S3
echo "$(date +'%Y-%m-%d %H:%M:%S'): Uploading backup file to S3 at $target_s3_path$"
sudo aws s3 cp $backup_dir$backup_file $target_s3_path

echo "$(date +'%Y-%m-%d %H:%M:%S'): Backup file uploaded to S3 successfully"
echo "$(date +'%Y-%m-%d %H:%M:%S'): Starting Bedrock server"
#start the Bedrock server after backup
sudo systemctl start bedrock.service
echo "$(date +'%Y-%m-%d %H:%M:%S'): Bedrock world backup process completed"

