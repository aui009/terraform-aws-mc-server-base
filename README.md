# terraform-aws-mc-server-base

## Overview

This repository deploys the foundational AWS infrastructure for the Minecraft server ecosystem. It creates Lambda layers, S3 buckets for server configuration, SQS queues for event handling, SSM parameters, SSM documents for server management, and Secrets Manager resources for API credentials.

The module supports two environments (`dev` and `prod`) with different scheduling configurations and uses Terraform workspaces to manage environment isolation.

## What is deployed

### Lambda Layers
- **discord_webhook_layer** — Discord webhook library for Python 3.14
- **requests_layer** — Requests library for HTTP calls
- **tenacity_py_layer** — Tenacity library for retry logic

### S3 Bucket
- **mc-server-config-files** — Stores Minecraft server configuration files, static files, and backup directories
  - Organized by server type: `bedrock/` and `java/` directories
  - Includes migration and backup subdirectories
  - EventBridge notification enabled for file changes

### SQS Queue
- **miku-test-queue** — Central message queue for Minecraft server events
  - Used for inter-service communication and event propagation
  - Queue policy configured for account-level access

### SSM Parameters
- **MC-environment** — Current environment identifier (dev/prod)
- **MC-server-time-sched-wkday** — Weekday server schedule (configurable per environment)
- **MC-server-time-sched-wkend** — Weekend server schedule (configurable per environment)

### SSM Documents
- **RunSSMWarningMsgCommand** — Sends warning messages to connected players
- **RunSSMBackupScriptCommand** — Executes backup scripts on the server
- **CreateSnapshotEc2Command** — Creates and tags EBS volume snapshots for backup

### Secrets Manager
- **bot_miku_api_keys** — Stores API credentials for the Miku bot

## Environment configurations

### Development (`dev`)
- Weekday schedule: 7 PM – 8 PM
- Weekend schedule: 7 PM – 8 PM
- Shorter retention periods for testing

### Production (`prod`)
- Weekday schedule: 7 PM – 12 AM
- Weekend schedule: 1 PM – 12 AM
- Full retention and monitoring

## Repository structure

- `main.tf` — core AWS resources (Lambda layers, S3, SQS, SSM, Secrets Manager)
- `locals.tf` — environment-specific configurations, scheduling, and file mappings
- `outputs.tf` — exported resource ARNs and IDs for downstream repositories
- `backend.tf` — S3 backend configuration
- `config/backend_dev.conf` — backend configuration for dev workspace
- `config/backend_prod.conf` — backend configuration for prod workspace
- `S3_files/mc-static-files/` — static files and configuration templates uploaded to S3
- `lambda_layer_files/` — pre-packaged Lambda layer ZIP files (discord_webhook, requests, tenacity)

## Deployment

1. Choose or create the workspace for the target environment:
   ```bash
   terraform workspace select dev || terraform workspace new dev
   ```

2. Initialize Terraform with the matching backend config:
   ```bash
   terraform init -backend-config=config/backend_dev.conf
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

For production, use `config/backend_prod.conf` and the `prod` workspace.

## Outputs

### Lambda Layers
- `discord_webhook_layer_arn` — ARN of the Discord webhook layer
- `requests_layer_arn` — ARN of the requests library layer
- `tenacity_py_layer_arn` — ARN of the tenacity library layer

### S3 and SQS
- `mc_server_config_files_bucket_id` — S3 bucket name for configuration files
- `miku_queue_url` — SQS queue URL for Minecraft events
- `miku_queue_sqs_arn` — SQS queue ARN

### SSM Documents
- `ssm_warning_msg_command_name` — Name of warning message command
- `ssm_backup_run_command_name` — Name of backup command
- `ssm_create_snapshot_ec2_command_arn` — ARN of snapshot creation command

## Dependencies

This repository has no external dependencies. It is a base layer deployed before other repositories:
- `terraform-aws-mc-server-iam-base`
- `minecraft_server_aws`
- `terraform-aws-mc-event-handler`

## Notes

- Lambda layer ZIP files must be pre-built and placed in `lambda_layer_files/`
- S3 bucket names must be globally unique; the workspace name is appended for uniqueness
- SSM parameters are tagged with workspace lifecycle ignore to allow manual updates
- The account ID used in the SQS policy (523761210076) should be updated to match your AWS account ID
- All resources are tagged with Environment and ManagedBy values
- AWS credentials must be configured before running Terraform
