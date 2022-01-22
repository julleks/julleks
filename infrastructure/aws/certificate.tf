resource "aws_acm_certificate" "certificate" {
  provider = aws.acm_provider
  domain_name = var.root_domain_name
  validation_method = "DNS"
  subject_alternative_names = ["*.${var.root_domain_name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  provider = aws.acm_provider
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_cname_record : record.fqdn]
}
