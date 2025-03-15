### main.tf

################################################################################
# S3 Bucket Configuration
################################################################################

# Creates an S3 bucket to store static website files
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.source_bucket_name
  tags   = var.tags
}

# Configures S3 bucket ownership to allow object ownership by the writer
resource "aws_s3_bucket_ownership_controls" "s3_bucket_owner" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

# Sets the bucket ACL to private to restrict access
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_owner]
  bucket     = aws_s3_bucket.s3_bucket.id
  acl        = "private"
}

# Blocks all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "s3_bucket_access" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Defines an S3 bucket policy allowing access from CloudFront and CodeBuild
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  depends_on = [
    aws_iam_role.codebuild_role,
    aws_cloudfront_distribution.cdn
  ]
  bucket = aws_s3_bucket.s3_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${var.source_bucket_name}/*"
        Condition = { "StringEquals" : { "AWS:SourceArn" : aws_cloudfront_distribution.cdn.arn } }
      },
      {
        Sid       = "AllowCodeBuildAccess"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.account_id}:role/${aws_iam_role.codebuild_role.name}" }
        Action    = "s3:*"
        Resource  = ["arn:aws:s3:::${var.source_bucket_name}", "arn:aws:s3:::${var.source_bucket_name}/*"]
      }
    ]
  })
}

################################################################################
# CloudFront Configuration
################################################################################

# Creates an Origin Access Control (OAC) for secure CloudFront access to S3
resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = var.cdn_name
  description                       = "${var.cdn_name} policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Creates a CloudFront distribution to serve static website content from S3
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name              = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cdn_name
  default_root_object = var.root_object_name

  aliases = local.domain_aliases

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    compress         = true

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"
  }

  # Handles custom error responses (redirects 403/404 errors to index.html)
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.tags

  # Configures SSL/TLS settings using ACM certificate
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}
