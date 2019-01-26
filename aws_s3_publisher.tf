locals {
  publisher_name = "travis-ci-deployer@pedrohdz.com"
}

resource "aws_iam_user" "publisher" {
  name = "${local.publisher_name}"
  #path = "/system/"
}

resource "aws_iam_access_key" "publisher" {
  user = "${aws_iam_user.publisher.name}"
}


data "template_file" "publisher_policy" {
  template = "${file("${path.module}/files/publisher-policy+template.json")}"
  vars = {
    bucket_name = "${aws_s3_bucket.site.bucket}"
  }
}

resource "aws_iam_user_policy" "publisher" {
  name = "publish-permissions"
  user = "${aws_iam_user.publisher.name}"

  policy = "${data.template_file.publisher_policy.rendered}"
}
