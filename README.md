# terraform-aws-cdn-with-codepipeline
This module will create:
- AWS CloudFront Distribution with an S3 Bucket as the origin.
- AWS CodePipeline and CodeBuild to build and copy content to the S3 bucket.
- AWS CodePipeline will also handle CloudFront invalidation.
- Necessary IAM roles for CloudFront and the pipeline.
- AWS ACM certificate and DNS records in Route53.

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