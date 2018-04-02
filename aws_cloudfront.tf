#----
# Main Site
#----
locals {
  site_origin_id          = "S3-Website+${aws_s3_bucket.site.website_endpoint}"
  site_redirect_origin_id = "S3-Website+${aws_s3_bucket.site_redirect.website_endpoint}"
}

data "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.logging_bucket}"
}

resource "aws_cloudfront_distribution" "site" {
  depends_on          = [ "aws_acm_certificate_validation.cert_validation" ]
  enabled             = true
  comment             = "The ${var.site} web site"
  aliases             = [ "${var.site}" ]
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  origin {
    origin_id                = "${local.site_origin_id}"
    domain_name              = "${aws_s3_bucket.site.website_endpoint}"
    custom_origin_config     = {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = [ "TLSv1", "TLSv1.1", "TLSv1.2" ]
    }
  }

  default_cache_behavior {
    target_origin_id       = "${local.site_origin_id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = [ "GET", "HEAD" ]
    cached_methods         = [ "GET", "HEAD" ]
    default_ttl            = "${var.cache_default_ttl}"
    compress               = true
    forwarded_values {
      query_string         = false
      cookies {
        forward            = "none"
      }
    }
  }

  custom_error_response {
    error_caching_min_ttl = "${var.cache_404_ttl}"
    error_code            = "404"
  }

  logging_config {
    bucket          = "${data.aws_s3_bucket.logging_bucket.bucket_domain_name}"
    include_cookies = "false"
    prefix          = "${var.cloudfront_logging_prefix}"
  }

  viewer_certificate {
    cloudfront_default_certificate = "false"
    acm_certificate_arn            = "${aws_acm_certificate.cert.arn}"
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }
}

#----
# Site Aliases/Redirects
#----
resource "aws_cloudfront_distribution" "site_redirect" {
  depends_on      = [ "aws_acm_certificate_validation.cert_validation" ]
  enabled         = true
  aliases         = [ "${var.domain_redirects}" ]
  comment         = "Redirect to ${var.site} via the ${local.site_redirect} S3 bucket"
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  origin {
    origin_id                = "${local.site_redirect_origin_id}"
    domain_name              = "${aws_s3_bucket.site_redirect.website_endpoint}"
    custom_origin_config     = {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = [ "TLSv1.2" ]
    }
  }

  default_cache_behavior {
    target_origin_id       = "${local.site_redirect_origin_id}"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = [ "GET", "HEAD" ]
    cached_methods         = [ "GET", "HEAD" ]
    default_ttl            = 300    # TODO: Change back to 86400 after testing?
    compress               = false
    forwarded_values {
      query_string         = false
      cookies {
        forward            = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = "false"
    acm_certificate_arn            = "${aws_acm_certificate.cert.arn}"
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }
}
