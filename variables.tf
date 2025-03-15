### variables.tf

################################################################################
# General Configuration Variables
################################################################################

variable "account_id" {
  description = "The AWS Account ID where all resources, including S3, CloudFront, and CodePipeline, will be deployed."
  type        = string
}

variable "region" {
  description = "The AWS region where infrastructure resources such as S3, CloudFront, and CodePipeline will be created."
  type        = string
}

variable "tags" {
  description = "A map of key-value pairs to apply as tags to all resources for better organization and cost tracking."
  type        = map(any)
}

################################################################################
# S3 and CloudFront Configuration
################################################################################

variable "source_bucket_name" {
  description = "The base name of the S3 bucket that stores static website files to be served via CloudFront."
  type        = string
}

variable "root_object_name" {
  description = "The default root object that CloudFront serves when a request is made to the distribution (e.g., index.html)."
  type        = string
  default     = "index.html"
}

variable "cdn_name" {
  description = "The user-defined name of the CloudFront distribution used for caching and serving static content."
  type        = string
}

variable "domain_name" {
  description = "The custom domain name associated with the CloudFront distribution (e.g., example.com)."
  type        = string
}

variable "zone_id" {
  description = "The Route 53 hosted zone ID for managing DNS records associated with the CloudFront distribution."
  type        = string
}

################################################################################
# CodePipeline Configuration
################################################################################

variable "pipeline_name" {
  description = "The name of the AWS CodePipeline, which automates the deployment process of static website assets to S3 and CloudFront."
  type        = string
}

variable "pipeline_bucket_name" {
  description = "The name of the S3 bucket that stores pipeline artifacts such as build outputs and deployment packages."
  type        = string
}

variable "source_connection_arn" {
  description = "The Amazon Resource Name (ARN) of the CodeStar connection used for integrating with a GitHub repository."
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository that serves as the source for the pipeline, formatted as 'owner/repo' (e.g., myorg/myrepo)."
  type        = string
}

variable "branch_name" {
  description = "The Git branch that triggers the pipeline execution when changes are pushed (e.g., 'main' or 'develop')."
  type        = string
}

variable "detect_branch_changes" {
  description = "A boolean flag indicating whether the pipeline should automatically detect changes in the specified branch and trigger a new build."
  type        = bool
  default     = true
}

################################################################################
# CodeBuild Configuration
################################################################################

variable "build_version" {
  description = "The version identifier for the CodeBuild project, which helps in tracking different builds."
  type        = string
  default     = "1"
}

variable "build_timeout" {
  description = "The maximum duration (in minutes) that a build process can run before being terminated."
  type        = number
  default     = 60
}

variable "compute_type" {
  description = "The type of compute resources allocated to the CodeBuild environment. Available options include BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, and BUILD_GENERAL1_LARGE."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  description = "The Docker image used in the CodeBuild environment to execute the build process (e.g., aws/codebuild/amazonlinux2-x86_64-standard:5.0)."
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "image_type" {
  description = "Specifies the type of Docker image used in the CodeBuild environment. Valid options include 'LINUX_CONTAINER' and 'WINDOWS_CONTAINER'."
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "privileged_mode" {
  description = "A boolean flag that enables privileged mode in CodeBuild, which is required for running Docker-in-Docker builds."
  type        = bool
  default     = false
}

variable "buildspec_file_name" {
  description = "The name of the build specification file (buildspec.yml) used by CodeBuild to define the build process."
  type        = string
  default     = "buildspec.yml"
}
