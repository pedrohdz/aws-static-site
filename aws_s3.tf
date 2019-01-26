#----
# Main site
#----
resource "aws_s3_bucket" "site" {
  bucket           = "${var.site}"
  acl              = "private"
  force_destroy    = "false"
  website          = {
    index_document = "index.html"
  }
}

data "aws_iam_policy_document" "site" {
  statement {
    sid           = "Public read access"
    effect        = "Allow"
    actions       = [ "s3:GetObject" ]
    resources     = [ "${aws_s3_bucket.site.arn}/*" ]

    principals {
      type        = "AWS"
      identifiers = [ "*" ]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket          = "${var.site}"
  policy          = "${data.aws_iam_policy_document.site.json}"
}


#----
# Site Aliases/Redirects
#----
resource "aws_s3_bucket" "site_redirect" {
  bucket                     = "${local.site_redirect}"
  acl                        = "private"
  force_destroy              = "false"
  website                    = {
    redirect_all_requests_to = "https://${var.site}"
  }
}
