#!/bin/bash

# Main Migration Script

migration_script_dir="/opt/minecraft/scripts/migration"
date_format=$(date +"%Y-%m-%d")

# Create a log file for the migration process
log_file="/opt/minecraft/logs/migration_$date_format.log"
touch "$log_file"

# Execute the Bedrock migration script
sudo bash "$migration_script_dir/migration_bedrock.sh" >> "$log_file" 2>&1

if [ $? -eq 0 ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S"): Bedrock world migration completed successfully" >> "$log_file"
else
    echo "$(date +"%Y-%m-%d %H:%M:%S"): Bedrock world migration failed with error code $?" >> "$log_file"
fi