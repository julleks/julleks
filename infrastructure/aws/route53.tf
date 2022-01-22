resource "aws_route53_zone" "primary" {
  name = var.root_domain_name
}

resource "aws_route53_record" "ns-record" {
  name = var.root_domain_name
  type = "NS"
  zone_id = aws_route53_zone.primary.zone_id
  records = [
    aws_route53_zone.primary.name_servers[0],
    aws_route53_zone.primary.name_servers[1],
    aws_route53_zone.primary.name_servers[2],
    aws_route53_zone.primary.name_servers[3],
  ]
  ttl = 172800
}

resource "aws_route53_record" "soa_record" {
  name = var.root_domain_name
  type = "SOA"
  zone_id = aws_route53_zone.primary.zone_id
  records = [
    "ns-116.awsdns-14.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
  ttl = 900
}

resource "aws_route53_record" "certificate_cname_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name = each.value.name
  type = each.value.type
  zone_id = aws_route53_zone.primary.zone_id
  records = [
    each.value.record
  ]
  ttl = 60
}

resource "aws_route53_record" "web_a_record" {
  for_each = var.environments

  name = each.value.domain_name
  type = "A"
  zone_id = aws_route53_zone.primary.zone_id

  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.web_cloudfront[each.key].domain_name
    zone_id = aws_cloudfront_distribution.web_cloudfront[each.key].hosted_zone_id
  }
}

resource "aws_route53_record" "www_web_a_record" {
  for_each = var.environments

  name = "www.${each.value.domain_name}"
  type = "A"
  zone_id = aws_route53_zone.primary.zone_id

  alias {
    evaluate_target_health = false
    name = "s3-website-eu-west-1.amazonaws.com"
    zone_id = aws_s3_bucket.www_web_bucket[each.key].hosted_zone_id
  }
}

resource "aws_route53_record" "mail_mx_record" {
  name = var.root_domain_name
  type = "MX"
  zone_id = aws_route53_zone.primary.zone_id

  records = [
    "10 mx.zoho.eu",
    "20 mx2.zoho.eu",
    "50 mx3.zoho.eu",
  ]
  ttl = 300
}

resource "aws_route53_record" "mail_domain_verification_record" {
  name = var.root_domain_name
  type = "TXT"
  zone_id = aws_route53_zone.primary.zone_id

  records = [
    "v=spf1 include:zoho.eu ~all",
    "zoho-verification=zb12550819.zmverify.zoho.eu",
  ]
  ttl = 300
}

resource "aws_route53_record" "mail_dkim_record" {
  name = "zmail._domainkey.${var.root_domain_name}"
  type = "TXT"
  zone_id = aws_route53_zone.primary.zone_id

  records = [
    "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCpgyflh/QRsvSuHgv4254J+yXINmToz+qhw9V3hAh4pRrJenU5533g+u2J4JvxyYPD0egK003MSSutUm4xP1dh9yIJJx0YY3G7dUDsZfCNiZAq0cTaL9Xru9OIP8hwbJus/5wzOFxlwjkL9rPqHoh62L4GHYABxlf9Flh1KonbNQIDAQAB",
  ]
  ttl = 300
}
