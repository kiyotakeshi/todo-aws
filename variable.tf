locals {
  app = "todo"
}

variable "region" {
  type = string
  description = "標準でリソースを構築するリージョン"
  default = "ap-northeast-1"
}
