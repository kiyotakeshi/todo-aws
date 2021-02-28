variable "app" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "associate_public_ip_address" {
  type = bool
  default = false
}

variable "subnet_id" {
  type = string
}

variable "user_data" {
  type = string
}

variable "public_key" {
  type = string
  # ssh-keygen -m PEM -t rsa -b 2048 -f todo_key -C ""
}

variable "vpc_id" {
  type = string
  description = "EC2の作成場所"
}
