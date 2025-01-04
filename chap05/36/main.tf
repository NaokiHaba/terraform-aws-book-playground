terraform {
  backend "local" {
    path = ".cache/terraform.tfstate"
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

