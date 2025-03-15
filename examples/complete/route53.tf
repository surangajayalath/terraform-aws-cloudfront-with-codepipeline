################################################################################
# AWS Route 53 Hosted Zone
################################################################################

# This resource creates a Route 53 hosted zone for the domain "example.com".
resource "aws_route53_zone" "primary" {
  name = "example.com"
}
