#----
# Main Site
#----
data "aws_route53_zone" "site" {
  name         = "${var.site}."
  private_zone = false
}

resource "aws_route53_record" "site" {
  zone_id = "${data.aws_route53_zone.site.zone_id}"
  name    = "${var.site}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.site.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.site.hosted_zone_id}"
    evaluate_target_health = false
  }
}

#----
# Site Aliases/Redirects
#----
data "aws_route53_zone" "site_redirect" {
  count        = "${length(var.domain_redirects)}"
  name         = "${element(var.domain_redirect_dns_zones, count.index)}"
  private_zone = false
}

resource "aws_route53_record" "site_redirect" {
  count   = "${length(var.domain_redirects)}"
  zone_id = "${data.aws_route53_zone.site_redirect.*.zone_id[count.index]}"
  name    = "${element(var.domain_redirects, count.index)}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.site_redirect.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.site_redirect.hosted_zone_id}"
    evaluate_target_health = false
  }
}

