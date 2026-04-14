locals {
  env_vars = {
    dev = {
      server_sched_time_wkday = "19:00 to 20:00"
      server_sched_time_wkend = "19:00 to 20:00"
    }
    prod = {
      server_sched_time_wkday = "19:00 to 00:00"
      server_sched_time_wkend = "13:00 to 00:00"
    }
    default = {

    }
  }

  tags = {
    "Environment" = terraform.workspace
    "ManagedBy"   = "Terraform"
  }

  empty_folders_bedrock = [
    "bedrock/migration/sucess/",
    "bedrock/migration/error/",
    "bedrock/backup/",

  ]

  empty_folders_java = [
    "java/migration/sucess/",
    "java/migration/error/",
    "java/backup/",
  ]

  region = "ap-southeast-1"

  environment = contains(keys(local.env_vars), terraform.workspace) ? terraform.workspace : "default"

  files_to_upload_mc_server = fileset("./S3_files/mc-static-files/", "**")

}