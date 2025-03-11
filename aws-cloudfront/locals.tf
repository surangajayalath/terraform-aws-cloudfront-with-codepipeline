### locals.tf

locals {
  s3_origin_id    = "s3OriginCloudFront"
  s3_bucket_name  = "${var.source_bucket_name}-${var.bucket_suffix}"
  domain_aliases  = ["${var.domain_name}.${var.domain_name}", "www.${var.domain_name}.${var.domain_name}"]
}