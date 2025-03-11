# output.tf

output "cdn_arn" {
  description = "The ARN of the CloudFront distribution."
  value       = aws_cloudfront_distribution.web_distribution.arn
}

output "cdn_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.web_distribution.id
}

output "cdn_domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.web_distribution.domain_name
}

output "cdn_hosted_zone_id" {
  description = "The hosted zone ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.web_distribution.hosted_zone_id
}