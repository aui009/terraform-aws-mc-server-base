locals{
    tags = {
        "Environment" = terraform.workspace
        "ManagedBy"   = "Terraform"
    }

    region = "ap-southeast-1"

    files_to_upload_mc_server = fileset("./S3_files/mc-static-files/", "**")

}