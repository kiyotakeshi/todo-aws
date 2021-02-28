// ref https://dev.classmethod.jp/articles/launch-ec2-from-latest-amazon-linux2-ami-by-terraform/
data "aws_ssm_parameter" "amazon_linux2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "ec2" {
  ami = data.aws_ssm_parameter.amazon_linux2_ami.value
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name = aws_key_pair.todo.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id = var.subnet_id
  user_data = var.user_data

  tags = {
    Name = var.app
  }
}

resource "aws_iam_instance_profile" "ec2" {
  name = var.app
  role = aws_iam_role.ec2.name
}

resource "aws_key_pair" "todo" {
  key_name = var.app
  public_key = var.public_key
}

resource "aws_iam_role" "ec2" {
  name = "${var.app}-ec2"
  // @see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role#basic-example
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = var.app
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.ec2.name
  // @see https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/setup-instance-profile.html#instance-profile-policies-overview
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "ec2" {
  name = "${var.app}-ec2"
  vpc_id = var.vpc_id
  tags = {
    Name = var.app
  }
}

resource "aws_security_group_rule" "egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
}

// You don't need to open ssh port
resource "aws_security_group_rule" "ingress_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
}
