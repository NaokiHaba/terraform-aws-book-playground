variable "aws_profile_name" {
  type = string
  default = "default"
}

provider "aws" {
  profile = var.aws_profile_name
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "current_region" {
  value = data.aws_region.current.name
}