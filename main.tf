####################################################################
#                         Lambda Layers                            #
####################################################################
resource "aws_lambda_layer_version" "discord_webhook_layer" {
  filename            = "${path.module}/lambda_layer_files/discord_webhook_layer.zip"
  layer_name          = "discord_webhook_layer"
  description         = "A Lambda layer containing the discord_webhook library"
  compatible_runtimes = ["python3.14"]

  source_code_hash = filebase64sha256("${path.module}/lambda_layer_files/discord_webhook_layer.zip")
}

resource "aws_lambda_layer_version" "requests_layer" {
  filename            = "${path.module}/lambda_layer_files/requests_layer.zip"
  layer_name          = "requests_layer"
  description         = "A Lambda layer containing the requests library"
  compatible_runtimes = ["python3.14"]

  source_code_hash = filebase64sha256("${path.module}/lambda_layer_files/requests_layer.zip")
}

resource "aws_lambda_layer_version" "tenacity_py_layer" {
  filename            = "${path.module}/lambda_layer_files/tenacity_package.zip"
  layer_name          = "tenacity_py_layer"
  description         = "A Lambda layer containing the tenacity library for Python"
  compatible_runtimes = ["python3.14"]

  source_code_hash = filebase64sha256("${path.module}/lambda_layer_files/tenacity_package.zip")
}

####################################################################
#                         S3 Bucket Configs                        #
####################################################################

resource "aws_s3_bucket" "mc_server_config-files" {
  bucket = "mc-server-${local.region}-config-files-${terraform.workspace}" # Bucket name must be globally unique
  tags   = local.tags
}

resource "aws_s3_bucket_notification" "mc_server_config_files_notification" {
  bucket      = aws_s3_bucket.mc_server_config-files.id
  eventbridge = true

}

resource "aws_s3_object" "upload_files_mc_server_config_files" {
  for_each = local.files_to_upload_mc_server
  bucket   = aws_s3_bucket.mc_server_config-files.id
  key      = each.value
  source   = "./S3_files/mc-static-files/${each.value}"
  etag     = filemd5("./S3_files/mc-static-files/${each.value}")
}

resource "aws_s3_object" "empty_folders_bedrock" {
  for_each     = toset(local.empty_folders_bedrock)
  bucket       = aws_s3_bucket.mc_server_config-files.id
  key          = each.value
  content_type = "application/x-directory"
}

resource "aws_s3_object" "empty_folders_java" {
  for_each     = toset(local.empty_folders_java)
  bucket       = aws_s3_bucket.mc_server_config-files.id
  key          = each.value
  content_type = "application/x-directory"
}

####################################################################
#                         AWS SSM Parameters                       
####################################################################

resource "aws_ssm_parameter" "environment" {
  name  = "MC-environment"
  type  = "String"
  value = local.environment
}

resource "aws_ssm_parameter" "server_time_sched_wkday" {
  name  = "MC-server-time-sched-wkday"
  type  = "String"
  value = local.env_vars[local.environment].server_sched_time_wkday
}

resource "aws_ssm_parameter" "server_time_sched_wkend" {
  name  = "MC-server-time-sched-wkend"
  type  = "String"
  value = local.env_vars[local.environment].server_sched_time_wkend
}

####################################################################
#                         AWS SSM Documents                       
####################################################################
resource "aws_ssm_document" "ssm_warning_msg_command" {
  name            = "RunSSMWarningMsgCommand"
  document_type   = "Command"
  target_type     = "/AWS::EC2::Instance"
  document_format = "JSON"

  content = <<DOC
  {
  "schemaVersion": "2.2",
  "description": "Command Document for running warning command",
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "example",
      "inputs": {
        "workingDirectory": "/opt/minecraft/scripts",
        "runCommand": [
          "sudo -u minecraft bash /opt/minecraft/scripts/send_warning_msg.sh"
        ]
      }
    }
  ]
  }
  DOC

}

resource "aws_ssm_document" "ssm_run_backup_script_command" {
  name            = "RunSSMBackupScriptCommand"
  document_type   = "Command"
  target_type     = "/AWS::EC2::Instance"
  document_format = "JSON"

  content = <<DOC
  {
  "schemaVersion": "2.2",
  "description": "Command Document for Backup Script in MC Server",
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "example",
      "inputs": {
        "workingDirectory": "/opt/minecraft/scripts",
        "runCommand": [
          "bash /opt/minecraft/scripts/backup_mc_script.sh"
        ]
      }
    }
  ]
  }
  DOC
}
####################################################################
#                         AWS SQS Queues                           
####################################################################
resource "aws_sqs_queue" "mc_server_miku_queue" {
  name                       = "miku-test-queue"
  delay_seconds              = 0
  visibility_timeout_seconds = 60
  max_message_size           = 1048576
  message_retention_seconds  = 60
  receive_wait_time_seconds  = 0

  tags = local.tags
}

resource "aws_sqs_queue_policy" "mc_server_miku_queue_policy" {
  queue_url = aws_sqs_queue.mc_server_miku_queue.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "__default_policy_ID",
    "Statement" : [
      {
        "Sid" : "__owner_statement",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::523761210076:root"
        },
        "Action" : "SQS:*",
        "Resource" : aws_sqs_queue.mc_server_miku_queue.arn
      }
    ]
  })
}

####################################################################
#                         AWS Secret Manager                          
####################################################################
resource "aws_secretsmanager_secret" "bot_miku_api_keys" {
  name        = "/${local.environment}/bot_miku_api_keys"
  description = "stores api keys for bot Miku"

}

import {
  to = aws_secretsmanager_secret.bot_miku_api_keys
  id = "arn:aws:secretsmanager:ap-southeast-1:523761210076:secret:/dev/bot_miku_api_keys-HT5yFA"
}