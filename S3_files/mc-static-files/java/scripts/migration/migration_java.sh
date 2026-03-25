#!/bin/bash
set -e
# Set environment variable for ssm parameter
ENV=$(sudo aws ssm get-parameter --name "MC-environment" --with-decryption --query Parameter.Value --output text)
MC_VERSION=java
MIGRATION_BACKUP_DIR="/opt/minecraft/backups/migration_backups/"
WORKING_DIR="/opt/minecraft/server/world/"
BACKUP_FILE=""$MC_VERSION"_migration_world_backup_$(date +%Y%m%d%H%M%S).zip"


echo "$(date +'%Y-%m-%d %H:%M:%S'): Starting Java world migration process"
cd /opt/minecraft/server/
# Stop the Java server before migration

echo "$(date +'%Y-%m-%d %H:%M:%S'): Stopping Java server before migration"
sudo systemctl stop minecraft_java.service

sudo mkdir migration_staging

# Backup current worlds files to S3 before migration
echo "$(date +'%Y-%m-%d %H:%M:%S'): Backing up current worlds files"
cd "$WORKING_DIR"
sudo zip -r $MIGRATION_BACKUP_DIR$BACKUP_FILE ./

# Copy existing server files to the staging directory
echo "$(date +'%Y-%m-%d %H:%M:%S'): Copying migration files to staging directory"
cd /opt/minecraft/server/
sudo aws s3 cp s3://mc-server-ap-southeast-1-config-files-$ENV/$MC_VERSION/migration/staging/target_mcworld.zip ./migration_staging/

# Unzip the target world file
echo "$(date +'%Y-%m-%d %H:%M:%S'): Extracting migration world file"
sudo unzip ./migration_staging/target_mcworld.zip -d ./migration_staging/

# Remove the zip file after extraction to clean up
sudo rm -rf ./migration_staging/target_mcworld.zip

# Clean up files in world directory
echo "$(date +'%Y-%m-%d %H:%M:%S'): Cleaning up existing world files"
sudo rm -rf ./world/*

# Move the unzipped world files to the server directory, overwriting existing files
echo "$(date +'%Y-%m-%d %H:%M:%S'): Moving migration world files to server world directory"
cp -r ./migration_staging/. ./world/

# Clean up staging directory after migration
echo "$(date +'%Y-%m-%d %H:%M:%S'): Cleaning up staging directory"
sudo rm -rf ./migration_staging

# Restart the Java server after migration
echo "$(date +'%Y-%m-%d %H:%M:%S'): Starting Java server"
sudo systemctl start minecraft_java.service
sudo systemctl start monitor_mc_java.service