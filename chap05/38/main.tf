terraform {
  backend "local" {
    path = ".cache/terraform.tfstate"
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "sqs-queue-20250104"
  # メッセージの保持期間（12時間）
  message_retention_seconds = 43200
  # ロングポーリングの待機時間（0秒=ショートポーリング）
  receive_wait_time_seconds = 0
  # メッセージの可視性タイムアウト（30秒）
  visibility_timeout_seconds = 30
}

resource "aws_sqs_queue" "fifo_queue" {
  name = "sqs-queue-20250104.fifo"

  # FIFOキューを有効にする
  fifo_queue = true

  # メッセージの重複排除
  content_based_deduplication = true
  # メッセージの保持期間（12時間）
  message_retention_seconds = 43200
  # ロングポーリングの待機時間（10秒）
  receive_wait_time_seconds = 10
  # メッセージの可視性タイムアウト（30秒）
  visibility_timeout_seconds = 30
}
