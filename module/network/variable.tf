variable "cidr_block" {
  type = string
  default = "172.31.0.0/16"
}

variable "enable_dns_support" {
  default = true
}

variable "enable_dns_hostnames" {
  default = true
}

variable "availability_zones" {
  type = list(string)
  default = ["ap-northeast-1c","ap-northeast-1d"]
}

variable "public_subnet_cidr" {
  type = list(string)
  default = ["172.31.0.0/24","172.31.1.0/24"]
}

variable "tag" {
  type = string
}