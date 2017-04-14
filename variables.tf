# Required

# Optional
variable "user_name" {
  description = "Name of User"
  default     = "loggly-s3-user"
}

variable "queue_name" {
  description = "Name of SQS Queue"
  default     = "loggly-s3-queue"
}

variable "bucket_name" {
  description = "Name of S3 bucket"
  default     = "my-bucket"
}

variable "bucket_prefix" {
  description = "Prefix for elb logs"
  default     = "elb-logs"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-southeast-1"
}
