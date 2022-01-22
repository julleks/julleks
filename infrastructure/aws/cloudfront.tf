resource "aws_cloudfront_distribution" "web-cloudfront" {
  for_each = var.environments

  enabled = true
  aliases = [each.value.domain_name]
  http_version = "http2"
  price_class  = "PriceClass_All"

  default_root_object = "index.html"
  is_ipv6_enabled = true

  origin {
    origin_id = aws_s3_bucket.web-bucket[each.key].bucket_regional_domain_name
    domain_name = aws_s3_bucket.web-bucket[each.key].bucket_regional_domain_name
    origin_path = ""

    connection_attempts = 3
    connection_timeout  = 10

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.web-cloudfront-identity.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    minimum_protocol_version = "TLSv1.2_2021"
    cloudfront_default_certificate = false
    acm_certificate_arn = aws_acm_certificate.certificate.arn
    ssl_support_method  = "sni-only"
  }

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    target_origin_id = aws_s3_bucket.web-bucket[each.key].bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"
    compress = true
  }

   custom_error_response {
     error_caching_min_ttl = 10
     error_code = 404
     response_code = 0
  }

  logging_config {
    bucket = aws_s3_bucket.logs-bucket.bucket_domain_name
    include_cookies = false
    prefix = "docs-${each.key}"
  }
}

resource "aws_cloudfront_origin_access_identity" "web-cloudfront-identity" {
  comment = "access-identity-julleks.com.s3.eu-west-1.amazonaws.com"
}
