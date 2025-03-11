data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.pipeline_bucket_name
}

data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
}