###########################################################
#                   Lambda Layer Outputs                  #
###########################################################

output "discord_webhook_layer_arn" {
  description = "The ARN of the Discord Webhook Lambda layer"
  value       = aws_lambda_layer_version.discord_webhook_layer.arn
}

output "requests_layer_arn" {
  description = "The ARN of the Requests Lambda layer"
  value       = aws_lambda_layer_version.requests_layer.arn
}

output "tenacity_py_layer_arn" {
  description = "The ARN of the Tenacity Python Lambda layer"
  value       = aws_lambda_layer_version.tenacity_py_layer.arn
}
###########################################################
#                   S3 Bucket Outputs                     #
###########################################################

output "mc_server_config_files_bucket_id" {
  description = "The ID of the S3 bucket for Minecraft server config files"
  value       = aws_s3_bucket.mc_server_config-files.id
}

###########################################################
#                   SQS Queue Outputs                     #
###########################################################

output "miku_queue_url" {
  description = "The URL of the SQS queue for Minecraft server Miku notifications"
  value       = aws_sqs_queue.mc_server_miku_queue.id
}

output "miku_queue_sqs_arn" {
  description = "The arn of of SQS queue for Minecraft server Miku notifications"
  value       = aws_sqs_queue.mc_server_miku_queue.arn
}

###########################################################
#                   SSM Document Outputs                   
###########################################################

output "ssm_warning_msg_command_name" {
  description = "The name of SSM Command ssm_warning_msg_command"
  value       = aws_ssm_document.ssm_warning_msg_command.name
}

output "ssm_backup_run_command_name" {
  description = "The name of SSM Command ssm_run_backup_script_command"
  value       = aws_ssm_document.ssm_run_backup_script_command.name
}

