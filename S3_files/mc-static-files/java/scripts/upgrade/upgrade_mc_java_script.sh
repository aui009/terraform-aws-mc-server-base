#!/bin/bash
set -e
#SET Environment variables
MINECRAFT_SERVER_URL="https://piston-data.mojang.com/v1/objects/3872a7f07a1a595e651aef8b058dfc2bb3772f46/server.jar"

MC_PREV_VERSION="1.21"

WORKING_DIR="/opt/minecraft/server/"
BACKUP_DIR="/opt/minecraft/backups/upgrade/"$MC_PREV_VERSION"_backup_mc_server_files_$(date +%Y%m%d%H%M%S)/"


#Create Backup DIR
mkdir -p $BACKUP_DIR
# Backup current server files to S3 before migration
echo "$(date +'%Y-%m-%d %H:%M:%S'): Backing up current server files"
cd "$WORKING_DIR"
cp -r  ./ $BACKUP_DIR

# Clean up files in world directory
echo "$(date +'%Y-%m-%d %H:%M:%S'): Cleaning up existing server files"
cd "$WORKING_DIR"
sudo rm -rf ./*

# Download latest MC Server files
wget $MINECRAFT_SERVER_URL

echo "eula=true" > eula.txt



