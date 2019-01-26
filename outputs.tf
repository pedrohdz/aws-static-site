output "publisher_id" {
  value = "${aws_iam_access_key.publisher.id}"
}

output "publisher_secret" {
  value = "${aws_iam_access_key.publisher.secret}"
}
