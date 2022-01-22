resource "aws_s3_bucket" "web-bucket" {
  for_each = var.environments

  bucket = each.value.domain_name

  policy = templatefile(
    "policies/s3-bucket-policy.tpl",
    {
      bucket_name = each.value.domain_name,
      origin_access_identity = aws_cloudfront_origin_access_identity.web-cloudfront-identity.id
    }
  )
}

resource "aws_s3_bucket" "www-web-bucket" {
  for_each = var.environments

  bucket = "www.${each.value.domain_name}"

  website {
    redirect_all_requests_to = "https://${each.value.domain_name}"
  }
}

resource "aws_s3_bucket" "logs-bucket" {
  bucket = "${var.project_name}-logs"

  policy = templatefile(
    "policies/s3-bucket-policy-logs.tpl",
    {
      bucket_name = "${var.project_name}-logs",
      account_id = var.account_id
    }
  )
}
