# aws-static-site
Terraform module for creating a static site served by AWS CloudFront and backed by S3.


## Design notes

- *S3* only allows *HTTP* access via its Website endpoint, hence *CloudFront's*
  `origin_protocol_policy` being set to `http-only`.
- Defaulting a URL path to `index.html` can only be handled by *S3* Websites.
  This is why *CloudFront* doesn **not** utilize the *S3* buckets directly.


## License
Apache 2 Licensed. See LICENSE for full details.

