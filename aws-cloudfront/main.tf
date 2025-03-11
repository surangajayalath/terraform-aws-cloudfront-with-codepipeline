### main.tf

resource "aws_s3_bucket" "s3_bucket" {
  bucket = local.s3_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_owner" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_owner]
  bucket     = aws_s3_bucket.s3_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_access" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = var.cdn_name
  description                       = "${var.cdn_name} policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${local.s3_bucket_name}/*"
        Condition = { "StringEquals" : { "AWS:SourceArn" : aws_cloudfront_distribution.cdn.arn } }
      },
      {
        Sid    = "AllowCodeBuildAccess"
        Effect = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.account_id}:role/codebuild_role_${var.pipeline_name}" }
        Action   = "s3:*"
        Resource = ["arn:aws:s3:::${local.s3_bucket_name}", "arn:aws:s3:::${local.s3_bucket_name}/*"]
      }
    ]
  })
}

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

  viewer_certificate {
    acm_certificate_arn      = var.cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

### route53.tf
resource "aws_route53_record" "cdn_dns" {
  for_each        = toset(["${var.domain_prefix}", "www.${var.domain_prefix}"])
  allow_overwrite = true
  name            = each.key
  type            = "A"
  zone_id         = var.zone_id

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = true
  }
}