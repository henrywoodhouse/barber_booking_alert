provider "aws" {
  version = "~> 2.0"
  region  = var.aws_region
}

resource "aws_iam_role" "lambda_role" {
  name = "barber_alert_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "secrets_manager" {
  name        = "barber_alert_secrets_manager_access"
  path        = "/"
  description = "Provides access to secrets manager"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account}:secret:TWILIO_AUTH_TOKEN",
        "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account}:secret:TWILIO_ACCOUNT_SID",
        "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account}:secret:TWILIO_PHONE_NUMBER",
        "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account}:secret:USER_PHONE_NUMBERS"
      ]
    }
  ]
}
EOF
}

resource "aws_lambda_function" "barber_lambda" {
  filename      = "lambda/lambda_function_payload.zip"
  function_name = "barber_booking_alert"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.handler"

  source_code_hash = filebase64sha256("lambda/lambda_function_payload.zip")

  runtime = "python3.8"

  environment {
    variables = {
      AWS_REGION = ${var.aws_region}
    }
}