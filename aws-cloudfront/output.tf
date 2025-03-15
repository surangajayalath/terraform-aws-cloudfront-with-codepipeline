# output.tf

output "cdn_arn" {
  description = "The ARN of the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.arn
}

output "cdn_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.id
}

output "cdn_domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cdn_hosted_zone_id" {
  description = "The hosted zone ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.hosted_zone_id
}

output "aws_codebuild_project_arn" {
   description = "Arn of the project"
   value       = aws_codebuild_project.codebuild_project.arn
 }

 output "aws_codebuild_project_name" {
   description = "name of the project"
   value       = aws_codebuild_project.codebuild_project.name
 }

 output "pipeline_name" {
   description = "name of the pipeline"
   value       = aws_codepipeline.codepipeline.name
 }