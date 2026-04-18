#!/bin/bash

set -e 

# Deployment and setup of cron job for script checkOnlinePlayers.sh
ENV=$(sudo aws ssm get-parameter --name "MC-environment" --with-decryption --query Parameter.Value --output text)
MC_VERSION=java
SH_SCRIPT_FILE="checkOnlinePlayers.sh"
CRON_EXPR="30 * * * * bash $SH_SCRIPT_FILE" 

echo "$(date +'%Y-%m-%d %H:%M:%S'): Downloading file from S3"
aws s3 cp s3://mc-server-ap-southeast-1-config-files-$ENV/$MC_VERSION/scripts/$SH_SCRIPT_FILE /opt/minecraft/scripts/

# Add cronjob to crontab file
echo "$(date +'%Y-%m-%d %H:%M:%S'): adding $SH_SCRIPT_FILE to cronjob with cron expression $CRON_EXPR"

# Write all cronjobs in temp file
crontab -l > mycron_temp

# Add cron expresion
echo $CRON_EXPR >> mycron_temp

# Run Crontab
crontab mycron_temp

# delete Temp File
rm mycron_temp

echo "$(date +'%Y-%m-%d %H:%M:%S'): Deployment done..."

