variable "region" {
    default = "us-east-2"
}

variable "shared_credentials_file" {
    default = ""
}

variable "profile" {
    default = "default"
}

provider "aws" {
    region = "${var.region}"
    shared_credentials_file = "${var.shared_credentials_file}"
    profile = "${var.profile}"
}


resource "aws_iam_role" "iam_for_terraform_lambda" {
    name = "terraform_lambda"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "terraform_lambda_iam_policy_basic_execution" {
  role = "${aws_iam_role.iam_for_terraform_lambda.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "allow_terraform_bucket" {
    statement_id = "AllowExecutionFromS3Bucket"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.terraform_func.arn}"
    principal = "s3.amazonaws.com"
    source_arn = "${aws_s3_bucket.terraform_bucket.arn}"
}

resource "aws_lambda_permission" "allow_terraform_bucket_2" {
    statement_id = "AllowExecutionFromS3Bucket"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.terraform_func_2.arn}"
    principal = "s3.amazonaws.com"
    source_arn = "${aws_s3_bucket.terraform_bucket.arn}"
}

resource "aws_lambda_function" "terraform_func" {
    s3_bucket = ""
    s3_key = ""
    function_name = ""
    role = "${aws_iam_role.iam_for_terraform_lambda.arn}"
    handler = "index.handler"
    runtime = "nodejs8.10"
}

resource "aws_lambda_function" "terraform_func_2" {
    s3_bucket = ""
    s3_key = ""
    function_name = ""
    role = "${aws_iam_role.iam_for_terraform_lambda.arn}"
    handler = "index.handler"
    runtime = "nodejs8.10"
}

resource "aws_s3_bucket" "terraform_bucket" {
    bucket = "app-terraform-dev"
}
resource "aws_s3_bucket_notification" "bucket_terraform_notification" {
    bucket = "${aws_s3_bucket.terraform_bucket.id}"
    lambda_function {
        lambda_function_arn = "${aws_lambda_function.terraform_func.arn}"
        events = ["s3:ObjectCreated:*"]
        filter_prefix = "content-packages/"
    }
    lambda_function {
        lambda_function_arn = "${aws_lambda_function.terraform_func_2.arn}"
        events = ["s3:ObjectCreated:*"]
        filter_prefix = "content-another/"
    }
}