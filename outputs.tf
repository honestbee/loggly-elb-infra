output "aws_account_number" {
    value = "${data.aws_caller_identity.current.account_id}"
}

output "loggly_aws_access_key_id" {
    value = "${aws_iam_access_key.loggly.id}"
}
output "loggly_aws_secret_access_key" {
    value = "${aws_iam_access_key.loggly.secret}"
}

output "loggly_sqs_queue_name" {
    value = "${aws_sqs_queue.s3_queue.name}"
}

output "loggly_s3_bucket_name" {
    value = "${aws_s3_bucket.elb_logs.id}"
}

output "loggly_s3_bucket_prefix" {
    value = "${var.bucket_prefix}"
}
