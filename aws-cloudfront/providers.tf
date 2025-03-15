provider "aws" {
  alias   = "secondary"
  region  = "us-east-1"
  profile = "shoutoutlabs-automation"
  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/deploy-role"
  }
}