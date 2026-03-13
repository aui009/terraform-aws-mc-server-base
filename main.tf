resource "aws_lambda_layer_version" "discord_webhook_layer" {
  filename   = "${path.module}/lambda_layer_files/discord_webhook_layer.zip"
  layer_name = "discord_webhook_layer"
  description = "A Lambda layer containing the discord_webhook library"
  compatible_runtimes = ["python3.14"]

  source_code_hash = filebase64sha256("${path.module}/lambda_layer_files/discord_webhook_layer.zip" )
}
