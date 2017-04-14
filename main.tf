provider "aws" {
  region = "${var.aws_region}"
}

# terraform import aws_s3_bucket.elb_logs honestbee-elb-logs
resource "aws_s3_bucket" "elb_logs" {
    bucket = "${var.bucket_name}"
    acl = "private"
    tags {
      Name = "ELB Logs"
      builtWith = "terraform"
    }
}
resource "aws_s3_bucket_policy" "elb_logs" {
  bucket = "${aws_s3_bucket.elb_logs.id}"
  policy = "${data.aws_iam_policy_document.elb_logs.json}"
}
data "aws_elb_service_account" "main" {}
data "aws_iam_policy_document" "elb_logs" {
  statement {
      sid = "1"
      principals {
        type  = "AWS"
        identifiers = ["${data.aws_elb_service_account.main.arn}"]
      }
      actions = [
        "s3:PutObject"
      ]
      resources = [
        "${aws_s3_bucket.elb_logs.arn}/${var.bucket_prefix}/AWSLogs/*"
      ]
  }
}

# queue to receive s3 notifications
resource "aws_sqs_queue" "s3_queue" {
  name = "${var.queue_name}"
}
resource "aws_sqs_queue_policy" "s3_queue" {
  queue_url = "${aws_sqs_queue.s3_queue.id}"
  policy = "${data.aws_iam_policy_document.s3_queue.json}"
}
data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "s3_queue" {
  # allow s3 bucket publish on queue
  statement {
    sid = "1"
    principals {
      type  = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "SQS:SendMessage"
    ]
    resources = [
      "${aws_sqs_queue.s3_queue.arn}"
    ]
    # condition = {
    #   test = "ArnLike"
    #   variable = "aws:SourceArn"
    #   values = ["arn:aws:s3:*:*:${aws_s3_bucket.elb_logs.id}"]
    # }
    condition = {
      test = "ArnEquals"
      variable = "aws:SourceArn"
      values = ["${aws_s3_bucket.elb_logs.arn}"]
    }
  }
  # give root account full permissions
  statement {
    sid = "2"
    principals {
      type  = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "SQS:*"
    ]
    resources = [
      "${aws_sqs_queue.s3_queue.arn}"
    ]
  }
}

# define loggly user and policy
resource "aws_iam_user" "loggly" {
    name = "${var.user_name}"
}
resource "aws_iam_user_policy" "loggly" {
  name = "loggly"
  user = "${aws_iam_user.loggly.name}"

  policy = "${data.aws_iam_policy_document.loggly.json}"
}
data "aws_iam_policy_document" "loggly" {
  # allow full access to sqs queue
  statement {
      sid = "1"
      actions = [
        "sqs:*"
      ]
      resources = [
        "${aws_sqs_queue.s3_queue.arn}"
      ]
  }
  # allow read access to s3 bucket
  statement {
      sid = "2"
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetBucketLocation"
      ]
      resources = [
        "${aws_s3_bucket.elb_logs.arn}",
        "${aws_s3_bucket.elb_logs.arn}/*"
      ]
  }
}

# enable s3 bucket to send notifications to s3 queue
resource "aws_s3_bucket_notification" "elb_logs" {
  bucket = "${aws_s3_bucket.elb_logs.id}"

  queue {
    queue_arn     = "${aws_sqs_queue.s3_queue.arn}"
    events        = ["s3:ObjectCreated:*"]
    # filter_suffix = ".log"
  }
}

# generate access key for loggly user
resource "aws_iam_access_key" "loggly" {
    user = "${aws_iam_user.loggly.name}"
}
