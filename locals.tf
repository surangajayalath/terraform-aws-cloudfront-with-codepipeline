################################################################################
# Local Variables
################################################################################

# Define a unique origin ID for the S3 bucket used in CloudFront distribution.
locals {
  s3_origin_id = "s3OriginCloudFront"

  # Define domain aliases to be used in CloudFront distribution.
  domain_aliases = ["${var.domain_name}", "www.${var.domain_name}"]
}
