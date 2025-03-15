################################################################################
# AWS KMS Alias for S3 Bucket Encryption
################################################################################

# This data source retrieves the AWS KMS key alias used for encrypting the 
# S3 bucket where artifacts will be stored.
data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
}
