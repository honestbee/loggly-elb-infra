# Terraform configuration for Loggly S3 Ingestion

This Terraform configuration automates the [AWS configuration for S3 Ingestion into Loggly](https://www.loggly.com/docs/s3-ingestion-manual/).

[The Python script](https://www.loggly.com/docs/s3-ingestion-auto) provided by Loggly to automate AWS configuration does not offer the change automation and execution plans Terraform does and is easy to break.

## Pre-Requisites

To use this Terraform configuration:

Install [Terraform](https://www.terraform.io/downloads.html) (tested with 0.9.3) and [aws-cli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html), also complete your aws-cli [configuration](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).

## Variables

Following variables are available for customisation:

| Name            | Description                         | Default           |
| --------------- | ----------------------------------- | ----------------- |
| `aws_region`    | The AWS region to use               | `ap-southeast-1`  |
| `user_name`     | Name of User                        | `loggly-s3-user`  |
| `queue_name`    | Name of SQS Queue                   | `loggly-s3-queue` |
| `bucket_name`   | Name of S3 bucket                   | `my-bucket`       |
| `bucket_prefix` | Prefix for elb logs                 | `elb-logs`        |

```bash
# through env vars
export TF_VAR_aws_region=ap-southeast-1
export TF_VAR_user_name=loggly-s3-user
export TF_VAR_queue_name=loggly-s3-queue
export TF_VAR_bucket_name=my-bucket
export TF_VAR_bucket_prefix=elb-logs

# or through variable file
curl -Lo terraform.tfvars https://raw.githubusercontent.com/honestbee/loggly-elb-infra/master/terraform.tfvars.example
```

## Usage

Clone this repository or run directly from git:

```bash
terraform init github.com/honestbee/loggly-elb-infra
```

### Planning changes

Use `terraform plan` to preview changes this configuration will apply to your AWS account:

```bash
terraform plan
```

Resources created and managed by this configuration:

- IAM User & access key for Loggly
- S3 Bucket with ELB policy and SQS Notifictations
- SQS Queue

### Working with existing buckets

By default the terraform plan will try to create a new s3 bucket.

If you have an existing bucket, use `terraform import aws_s3_bucket.elb_logs <name of bucket>`.

```bash
terraform import aws_s3_bucket.elb_logs my-bucket
> aws_s3_bucket.elb_logs: Importing from ID "my-bucket"...
> aws_s3_bucket.elb_logs: Import complete!
>   Imported aws_s3_bucket (ID: my-bucket)
>   Imported aws_s3_bucket_policy (ID: my-bucket)
> aws_s3_bucket.elb_logs: Refreshing state... (ID: my-bucket)
> aws_s3_bucket_policy.elb_logs: Refreshing state... (ID: my-bucket)
>
> Import success! The resources imported are shown above. These are
> now in your Terraform state. ...
> ...
```

**Note**: Pay close attention to the Terraform plan to ensure no unintended changes are applied to your existing `bucket` or `bucket_policy`.

### Applying changes

Once happy with the plan, apply the configuration changes:

```bash
terraform apply
```

Once completed, the end result may look as follows:

```
...
Apply complete! Resources: 6 added, 2 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path:

Outputs:

aws_account_number = ...
loggly_aws_access_key_id = ...
loggly_aws_secret_access_key = ...
loggly_s3_bucket_name = ...
loggly_s3_bucket_prefix = ...
loggly_sqs_queue_name = ...
```

All values required for Loggly configuration are available as outputs of the configuration.

To print this information again:

```
terraform output
```
