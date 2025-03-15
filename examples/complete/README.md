################################################################################
# terraform-aws-cdn-with-codepipeline
################################################################################

# Configure AWS profile
## Input Values for profile configuration
- AWS SECRET KEY
- AWS SECRET KEY ID
- REGION

## Command
``` aws configure --profile aws-profile ```

# Provider configuration
```
provider "aws" {
  profile = "aws-profile"
  region  = "us-east-1"
  alias   = "secondary"

  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/deploy-role"
    session_name = "session-${var.account_id}"
  }
}
```

# Import module and configuration
```
module "cdn" {
  source                = "git::https://github.com/surangajayalath/terraform-aws-cdn-with-codepipeline"
  account_id            = "12345678901234"
  region                = "us-east-1"
  root_object_name      = "index.html"
  domain_name           = "devops.app.example.com"
  source_bucket_name    = "devops-app-build-files-us-east-1"
  cdn_name              = "devops-app-cdn"
  zone_id               = "GVD5678EDCVBG"
  pipeline_name         = "devops-app-cdn-deployment-pipeline"
  pipeline_bucket_name  = "devops-app-cdn-deployment-pipeline-artifact-us-east-1"  # for artifact storage
  source_connection_arn = "arn:aws:codeconnections:us-east-1:12345678901234:connection/dafc488c-8fc5-3159d072f3-cb86-bdfsdgd"
  github_repo           = "{github-username}/{source-file-repo-name}"
  branch_name           = "main"
  buildspec_file_name   = "buildspec.yml"
  tags                  = { environment = "dev" }
  
  providers = {
    aws = aws.secondary
  }
}
```