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



################################################################################
# Variables
################################################################################

variable "project_name" {
  description = "The name of the project. Used in resource naming."
  type        = string
}

variable "pipeline_name" {
  description = "Name of the AWS CodePipeline."
  type        = string
}

variable "region" {
  description = "AWS region where resources will be created."
  type        = string
}

variable "pipeline_bucket_name" {
  description = "S3 bucket name for storing pipeline artifacts."
  type        = string
}

variable "source_connection_arn" {
  description = "ARN of the CodeStar connection to GitHub."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in 'owner/repo' format."
  type        = string
}

variable "branch_name" {
  description = "Branch to be used in the pipeline source stage."
  type        = string
}

variable "detect_branch_changes" {
  description = "Whether to enable automatic detection of branch changes."
  type        = bool
  default     = true
}

variable "build_version" {
  description = "CodeBuild version."
  type        = string
  default     = "1"
}

variable "build_timeout" {
  description = "Timeout for the build process in minutes."
  type        = number
  default     = 60
}

variable "compute_type" {
  description = "Compute type for the CodeBuild environment."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  description = "Docker image for the CodeBuild environment."
  type        = string
  default = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "image_type" {
  description = "Type of the Docker image used in CodeBuild."
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "privileged_mode" {
  description = "Whether to enable privileged mode in CodeBuild."
  type        = bool
  default     = false
}

variable "buildspec_file_name" {
  description = "The buildspec file used for CodeBuild."
  type        = string
  default     = "buildspec.yml"
}