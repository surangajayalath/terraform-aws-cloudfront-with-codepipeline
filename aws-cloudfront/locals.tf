### locals.tf

locals {
  s3_origin_id    = "s3OriginCloudFront"
  domain_aliases  = ["${var.domain_name}.${var.domain_name}", "www.${var.domain_name}.${var.domain_name}"]
}