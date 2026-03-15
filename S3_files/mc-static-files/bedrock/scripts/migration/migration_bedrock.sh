#!/bin/bash
echo "$(date +'%Y-%m-%d %H:%M:%S'): Starting Bedrock world migration process"
cd /opt/minecraft/server/
# Stop the Bedrock server before migration

echo "$(date +'%Y-%m-%d %H:%M:%S'): Stopping Bedrock server before migration"
sudo systemctl stop bedrock.service

sudo mkdir migration_staging worlds_backup

# Backup current worlds files to S3 before migration
echo "$(date +'%Y-%m-%d %H:%M:%S'): Backing up current worlds files"
sudo cp -r worlds worlds_backup

# Copy existing server files to the staging directory
echo "$(date +'%Y-%m-%d %H:%M:%S'): Copying migration files to staging directory"
sudo aws s3 cp s3://mc-server-ap-southeast-1-config-files-dev/bedrock/migration/staging/target_mcworld.zip ./migration_staging/

# Unzip the target world file
echo "$(date +'%Y-%m-%d %H:%M:%S'): Extracting migration world file"
sudo unzip ./migration_staging/target_mcworld.zip -d ./migration_staging/

# Remove the zip file after extraction to clean up
sudo rm -rf ./migration_staging/target_mcworld.zip

# Clean up files in worlds directory
echo "$(date +'%Y-%m-%d %H:%M:%S'): Cleaning up existing world files"
sudo rm -rf ./worlds/'Bedrock level'/*

# Move the unzipped world files to the server directory, overwriting existing files
echo "$(date +'%Y-%m-%d %H:%M:%S'): Moving migration world files to server world directory"
sudo cp -r ./migration_staging/target_mcworld/* ./worlds/'Bedrock level'/

# Clean up staging directory after migration
echo "$(date +'%Y-%m-%d %H:%M:%S'): Cleaning up staging directory"
sudo rm -rf ./migration_staging

# Restart the Bedrock server after migration
echo "$(date +'%Y-%m-%d %H:%M:%S'): Starting Bedrock server"
sudo systemctl start bedrock.service
