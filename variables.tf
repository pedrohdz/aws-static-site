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

variable "cache_default_ttl" {
  description = "Default CloudFront TTL."
}

variable "cache_404_ttl" {
  description = "404 response TTL."
}
