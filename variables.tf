variable "site" {
  description = "Hostname of the site."
}

variable "site_dns_zone" {
  description = "AWS DNS zone for the site's hostname. Used to update DNS records."
}

variable "domain_redirects" {
  description = "Hostnames that will rediredt to the main site."
  default     = []
}

variable "domain_redirect_dns_zones" {
  description = "AWS DNS zones for the domain_redirects.  Must be in the same order as domain_redirects."
  default     = []
}

variable "logging_bucket" {
  description = "S3 bucket to log S3 and CloudFront activity to."
}

variable "site_logging_prefix" {
  description = "S3 prefix to store S3 access logs to."
}

variable "cloudfront_logging_prefix" {
  description = "S3 prefix to store CloudFront access logs to."
}

variable "cache_default_ttl" {
  description = "Default CloudFront TTL."
}

variable "cache_404_ttl" {
  description = "404 response TTL."
}
