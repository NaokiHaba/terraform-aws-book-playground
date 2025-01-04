resource "aws_iam_role" "lambda_function_role" {
  name = "lambda_function_role"
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

resource "aws_iam_role_policy" "lambda_function_policy" {
  name = "lambda_function_policy"
  role = aws_iam_role.lambda_function_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.lambda_function_test_bucket.arn,
          "${aws_s3_bucket.lambda_function_test_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_function_policy_attachment" {
  role       = aws_iam_role.lambda_function_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = ".cache/lambda_function.zip"
}

resource "aws_lambda_function" "s3_trigger_lambda" {
  function_name    = "s3_trigger_lambda"
  role             = aws_iam_role.lambda_function_role.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.lambda_function_zip.output_path
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256
  timeout          = 30
}