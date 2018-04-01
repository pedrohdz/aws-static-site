# Certificate must be created in `us-east-1` to work with CloudFront:
#
#   To use an ACM Certificate with Amazon CloudFront, you must request or
#   import the certificate in the US East (N. Virginia) region. ACM
#   Certificates in this region that are associated with a CloudFront
#   distribution are distributed to all the geographic locations configured for
#   that distribution.
#
#   --  (https://docs.aws.amazon.com/acm/latest/userguide/acm-regions.html)
#
provider "aws" {
  alias  = "cert_provider_us_east_1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cert" {
  provider                  = "aws.cert_provider_us_east_1"
  domain_name               = "${var.site}"
  validation_method         = "DNS"
  subject_alternative_names = "${var.domain_redirects}"
}

# The reasoning behind `site_to_zone_name` is just for in case the output
# from aws_acm_certificate.cert.domain_validation_options not stable or does
# not match the order of the inputs.  This is a bit hacky, but helps to ensure
# stability.
locals {
  site_to_zone_name = "${zipmap(concat(list(var.site), var.domain_redirects), concat(list(var.site_dns_zone), var.domain_redirect_dns_zones))}"
}

# `count` is calculated with `length(var.domain_redirects) + 1` because of a bug in
# Terraform where the length from
# `aws_acm_certificate.cert.domain_validation_options` is not available until
# after creation, and dependency issues.  This is detailed in:
#
#    - https://github.com/hashicorp/terraform/issues/17315
#
data "aws_route53_zone" "cert_validation" {
  count        = "${length(var.domain_redirects) + 1}"
  name         = "${lookup(local.site_to_zone_name, lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "domain_name"))}."
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  count      = "${length(var.domain_redirects) + 1}"
  zone_id    = "${data.aws_route53_zone.cert_validation.*.zone_id[count.index]}"
  name       = "${lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_name")}"
  type       = "${lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_type")}"
  records    = [ "${lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_value")}" ]
  ttl        = 300
}

# The following watches and waits (blocks) for the validation to succeed.
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = "aws.cert_provider_us_east_1"
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = [ "${aws_route53_record.cert_validation.*.fqdn}" ]
  timeouts {
    create                = "1h"
  }
}
