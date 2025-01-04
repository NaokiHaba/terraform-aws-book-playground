terraform {
  backend "local" {
    path = ".cache/terraform.tfstate"
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

locals {
  lambda_function_names = [
    "lambda_function_one",
    "lambda_function_two",
  ]
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-20250104"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "managed_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_functions" {
  for_each    = toset(local.lambda_function_names)
  type        = "zip"
  source_file = "${each.value}.py"
  output_path = ".cache/${each.value}.zip"
}

resource "aws_lambda_function" "lambda_functions" {
  for_each         = toset(local.lambda_function_names)
  filename         = data.archive_file.lambda_functions[each.value].output_path
  function_name    = "step-function-lambda-${each.value}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "${each.value}.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_functions[each.value].output_base64sha256
}

resource "aws_iam_role" "step_function_role" {
  name = "step-function-role-20250104"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_function_policy" {
  name = "step-function-policy-20250104"
  role = aws_iam_role.step_function_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "lambda:InvokeFunction"
        Effect = "Allow"
        Resource = [
          for lambda_function in aws_lambda_function.lambda_functions : lambda_function.arn
        ]
      }
    ]
  })
}

resource "aws_sfn_state_machine" "step_function" {
  name     = "step-function-20250104"
  role_arn = aws_iam_role.step_function_role.arn
  definition = templatefile("state_machine_definition.json.tftpl", {
    lambda_one_arn = aws_lambda_function.lambda_functions["lambda_function_one"].arn
    lambda_two_arn = aws_lambda_function.lambda_functions["lambda_function_two"].arn
  })
}
