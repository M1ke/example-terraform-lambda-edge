variable "aws_region" {
  description = "Your region"
  default = "eu-west-1"
}

variable "password" {
	description = "A simple environment variable usage"
	# Much secure. So unhackable. Wow
	default = "p@ssword"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.0"
}

data "archive_file" "my-function" {
  type        = "zip"
  output_path = "./my-function.zip"
  source {
    content  = templatefile("./index.js", { password = var.password})
    filename = "index.js"
  }
}

resource "aws_iam_role" "my-role" {
  name = "template-variable-demo"
  path = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "my-role" {
  name = "template-variable-demo"
  role = aws_iam_role.my-role.name
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
POLICY
}

resource "aws_lambda_function" "my-lambda" {
  function_name = "template-variable-demo"
  role = aws_iam_role.my-role.arn
  filename = data.archive_file.my-function.output_path
  source_code_hash = data.archive_file.my-function.output_base64sha256
  runtime = "nodejs12.x"
  handler = "index.handler"
  publish = true

 // No environment variables now :-(
}
