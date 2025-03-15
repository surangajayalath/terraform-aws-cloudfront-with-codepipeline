################################################################################
# Terraform Provider Configuration
################################################################################

# Specify the required AWS provider version.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.48.0"
    }
  }
}

# AWS provider configuration
provider "aws" {
  profile = "aws-profile"  # AWS profile to use
  region  = "us-east-1"     # AWS region
  alias   = "secondary"     # Provider alias
}
