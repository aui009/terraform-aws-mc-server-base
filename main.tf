####################################################################
#                         Lambda Layers                            #
####################################################################
resource "aws_lambda_layer_version" "discord_webhook_layer" {
  filename   = "${path.module}/lambda_layer_files/discord_webhook_layer.zip"
  layer_name = "discord_webhook_layer"
  description = "A Lambda layer containing the discord_webhook library"
  compatible_runtimes = ["python3.14"]

  source_code_hash = filebase64sha256("${path.module}/lambda_layer_files/discord_webhook_layer.zip" )
}

resource "aws_lambda_layer_version" "requests_layer" {
  filename   = "${path.module}/lambda_layer_files/requests_layer.zip"
  layer_name = "requests_layer"
  description = "A Lambda layer containing the requests library"
  compatible_runtimes = ["python3.14"]

  source_code_hash = filebase64sha256("${path.module}/lambda_layer_files/requests_layer.zip" )
}

####################################################################
#                         S3 Bucket Configs                        #
####################################################################

resource "aws_s3_bucket" "mc_server_config-files" {
  bucket = "mc-server-${local.region}-config-files-${terraform.workspace}" # Bucket name must be globally unique
  tags   = local.tags
}

resource aws_s3_bucket_notification "mc_server_config_files_notification" {
  bucket = aws_s3_bucket.mc_server_config-files.id
  eventbridge = true

}

resource aws_s3_object "upload_files_mc_server_config_files" {
  for_each = local.files_to_upload_mc_server
  bucket = aws_s3_bucket.mc_server_config-files.id
  key = each.value
  source = "./S3_files/mc-static-files/${each.value}"
  etag = filemd5("./S3_files/mc-static-files/${each.value}")
}

resource aws_s3_object "empty_folders_bedrock" {
  for_each = toset(local.empty_folders_bedrock)
  bucket = aws_s3_bucket.mc_server_config-files.id
  key = each.value
  content_type = "application/x-directory"
}

####################################################################
#                         AWS SSM Parameters                       #
####################################################################

resource aws_ssm_parameter "environment" {
  name = "MC-environment"
  type = "String"
  value = locals.environment
}

####################################################################
#                         AWS SQS Queues                           #
####################################################################
import {
  to = aws_sqs_queue.mc_server_miku_queue
  identity = {
    url = "https://sqs.ap-southeast-1.amazonaws.com/523761210076/miku-test-queue"
  }
}

resource "aws_sqs_queue" "mc_server_miku_queue" {
  name = "miku-test-queue"
  delay_seconds = 0
  visibility_timeout_seconds = 60
  max_message_size = 1024
  message_retention_seconds = 84600
  receive_wait_time_seconds = 10

  tags = local.tags
}

resource aws_sqs_queue_policy "mc_server_miku_queue_policy" {
  queue_url = aws_sqs_queue.mc_server_miku_queue.id
  policy = jsonencode({
  "Version": "2012-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::523761210076:root"
      },
      "Action": "SQS:*",
      "Resource": aws_sqs_queue.mc_server_miku_queue.arn
    }
  ]
})
}