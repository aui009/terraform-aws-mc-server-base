locals{
    env_vars ={
        dev = {

        }
        prod = {

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
        "java/migration/sucess/",
        "java/migration/error/",
        "java/backup/",
    ]

    region = "ap-southeast-1"

    environment = contains(keys(local.env_vars), terraform.workspace) ? terraform.workspace : "default"

    files_to_upload_mc_server = fileset("./S3_files/mc-static-files/", "**")

}