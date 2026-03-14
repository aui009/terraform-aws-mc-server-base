locals{
    tags = {
        "Environment" = terraform.workspace
        "ManagedBy"   = "Terraform"
    }

    empty_folders_bedrock = [
        "bedrock/migration/sucess/",
        "bedrock/migration/error/"
    ]

    region = "ap-southeast-1"

    files_to_upload_mc_server = fileset("./S3_files/mc-static-files/", "**")

}