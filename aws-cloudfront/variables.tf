### variables.tf
variable "account_id" {
description = "The account ID of the AWS account where the S3 bucket is located."
  type = string
}

variable "domain_name" {
  description = "The domain name for the CloudFront distribution."
  type        = string
}

variable "source_bucket_name" {
  description = "The base name of the S3 bucket."
  type        = string
}

variable "root_object_name" {
  description = "The default root object for CloudFront (e.g., index.html)."
  type        = string
  default     = "index.html"
}

variable "cdn_name" {
  description = "The name of the CloudFront CDN distribution."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to resources."
  type        = map(any)
}

variable "zone_id" {
  description = "The Route 53 hosted zone ID for domain registration."
  type        = string
}

variable "pipeline_name" {
  description = "The name of the CI/CD pipeline that requires access to the S3 bucket."
  type        = string
}