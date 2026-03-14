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
  
}