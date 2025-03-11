### locals.tf

locals {
  s3_origin_id    = "s3OriginCloudFront"
  s3_bucket_name  = "${var.source_bucket_name}-${var.bucket_suffix}"
  domain_aliases  = ["${var.domain_prefix}.${var.domain_root}", "www.${var.domain_prefix}.${var.domain_root}"]
}