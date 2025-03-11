variable "project_name" {
  type = string
}

variable "pipeline_name" {
  type = string
}

variable "source_connection_arn" {
  type = string
}

variable "description" {
  type    = string
  default = "terrafrom managed project"
}

variable "compute_type" {
  type    = string
  default = "BUILD_GENERAL1_MEDIUM"
}

variable "image" {
  type    = string
  default = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "image_type" {
  type    = string
  default = "LINUX_CONTAINER"
}

variable "build_timeout" {
  type    = number
  default = 60
}

variable "npm_pkg_token_path" {
  type    = string
  default = "/shared/codeBuild/shoutout/github/token"
}

variable "git_user_token" {
  type    = string
  default = "/shared/codeBuild/shoutout/github/user_token"
}

variable "git_user_name" {
  type    = string
  default = "/shared/codeBuild/shoutout/github/user_name"
}

variable "github_repo" {
  type = string
}

variable "branch_name" {
  type    = string
  default = "development"
}

variable "detect_branch_changes" {
  type = string
  default = "true"
}

variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "source_version" {
  type    = number
  default = 1

}

variable "build_version" {
  type    = number
  default = 1
}

# variable "bucket_suffix" {
#   type = string

# }

variable "privileged_mode" {
  type    = bool
  default = true
}

variable "pipeline_bucket_name" {
  type = string

}

variable "buildspec_file_name" {
  type    = string
  default = "buildspec.yml"
}

variable "aws_kms_alias" {
  type = string
  default = "alias/aws/s3"
}