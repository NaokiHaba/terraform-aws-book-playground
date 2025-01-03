# アカウントIDをTF経由で取得できる
data "aws_caller_identity" "current" {}

# https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/lambda-intro-execution-role.html
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

# https://dev.classmethod.jp/articles/terraform-ml-yolox-lambda/
resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.lambda_function.function_name}:*",
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_function_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}


# TerraformがZIPファイルを作成してくれる
# このアプローチを取らない場合は、事前にZIPファイルを作成しておくかS3に配置しておく必要がある
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./lambda_function.js"
  output_path = ".cache/lambda_function.zip"
}


resource "aws_lambda_function" "lambda_function" {
  function_name    = "hello_lambda_function"
  filename         = data.archive_file.lambda.output_path

  # ハンドラーはLambda関数のエントリーポイントを指定する
  handler          = "lambda_function.lambda_handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  role             = aws_iam_role.lambda_function_role.arn
}

# 1分ごとに実行されるイベントルール
resource "aws_cloudwatch_event_rule" "lambda_event_rule" {
  name = "lambda_event_rule"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda_event_target" {
  rule = aws_cloudwatch_event_rule.lambda_event_rule.name
  target_id = aws_lambda_function.lambda_function.function_name
  arn = aws_lambda_function.lambda_function.arn
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission
resource "aws_lambda_permission" "lambda_permission" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.lambda_event_rule.arn
}