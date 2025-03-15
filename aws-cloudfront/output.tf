################################################################################
# CloudFront Distribution Outputs
################################################################################

# The Amazon Resource Name (ARN) of the CloudFront distribution.
output "cdn_arn" {
  description = "The ARN of the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.arn
}

# The unique identifier (ID) of the CloudFront distribution.
output "cdn_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.id
}

# The domain name assigned to the CloudFront distribution.
output "cdn_domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.domain_name
}

# The hosted zone ID associated with the CloudFront distribution.
output "cdn_hosted_zone_id" {
  description = "The hosted zone ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.hosted_zone_id
}

################################################################################
# CodeBuild Outputs
################################################################################

# The Amazon Resource Name (ARN) of the CodeBuild project.
output "aws_codebuild_project_arn" {
  description = "ARN of the CodeBuild project."
  value       = aws_codebuild_project.codebuild_project.arn
}

# The name of the CodeBuild project.
output "aws_codebuild_project_name" {
  description = "Name of the CodeBuild project."
  value       = aws_codebuild_project.codebuild_project.name
}

################################################################################
# CodePipeline Outputs
################################################################################

# The name of the CodePipeline.
output "pipeline_name" {
  description = "Name of the CodePipeline."
  value       = aws_codepipeline.codepipeline.name
}
