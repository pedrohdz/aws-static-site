# Global locals.  :-p
locals {
  site_redirect = "s3-site-redirect-to-${replace(var.site, "/\\./", "-")}.${var.site}"
}
