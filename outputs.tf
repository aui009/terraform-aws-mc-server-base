output "discord_webhook_layer_arn" {
  description = "The ARN of the Discord Webhook Lambda layer"
  value       = aws_lambda_layer_version.discord_webhook_layer.arn
}