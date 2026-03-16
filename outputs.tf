output "discord_webhook_layer_arn" {
  description = "The ARN of the Discord Webhook Lambda layer"
  value       = aws_lambda_layer_version.discord_webhook_layer.arn
}

output "mc_server_config_files_bucket_id" {
  description = "The ID of the S3 bucket for Minecraft server config files"
  value       = aws_s3_bucket.mc_server_config-files.id
}

output "miku_queue_url" {
  description = "The URL of the SQS queue for Minecraft server Miku notifications"
  value       = aws_sqs_queue.mc_server_miku_queue.id
}