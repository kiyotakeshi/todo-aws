terraform {
  required_version = "~> 0.14.0"
  // create bucket in advance
  // @see README.md
  backend "s3" {
    bucket = "kiyotake-todo-terraform"
    key = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = var.region
}
