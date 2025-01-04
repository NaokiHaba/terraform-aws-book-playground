locals {
  bucket_name = "lambda-function-test-bucket-20250104"
}

resource "aws_s3_bucket" "lambda_function_test_bucket" {
  bucket        = local.bucket_name
  force_destroy = true
}

# S3バケットからLambda関数を呼び出すためのIAMパーミッション
resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowS3Invoke"

  # Lambda関数の実行アクション
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_trigger_lambda.function_name

  # パーミッションを付与するAWSサービス
  principal = "s3.amazonaws.com"

  # 特定のS3バケットからのみLambda関数呼び出しを許可
  source_arn = aws_s3_bucket.lambda_function_test_bucket.arn
}


# 指定したS3バケットのイベントをLambda関数に通知する
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.lambda_function_test_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_trigger_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}



