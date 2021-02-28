module "network" {
  source = "./module/network"
  tag = local.app
}

module "ec2" {
  source = "./module/ec2"

  # @see https://aws.amazon.com/jp/ec2/instance-types/
  # If you want to use docker, then lack of memory
  # $ docker-compose -f app.yaml logs
  #  todo        | fixed memory regions require 627772K which is greater than 611008K available for allocation: -XX:MaxDirectMemorySize=10M, -XX:MaxMetaspaceSize=115772K, -XX:ReservedCodeCacheSize=240M, -Xss1M * 250 threads
  #  todo        | ERROR: failed to launch: exec.d: failed to execute exec.d file at path '/layers/paketo-buildpacks_bellsoft-liberica/helper/exec.d/memory-calculator': exit status 1
  # instance_type = "t2.small"
  # user_data = file("./user_data.sh")

  # not use docker case
  # instance type is "t2.micro"
  user_data = file("./user_data_not_use_docker.sh")

  app = local.app
  associate_public_ip_address = true // ELB は使用しないため
  subnet_id = module.network.public_subnet_ids[0]
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClNT82nes7EFfJzf5ug/kpn4V8+DVh6i+MFFFMwqo7Zdl3lZ1FmXPq/iHpQblMH1BgupHgdwiGahu5unNGc/9Dn4uegUImsAReCcx826ISWKB59WyW5mBPvMZHr+uoWbtWAudEcY6xeO6MZjC1pepgxdIuzzcFi1LVNIi72bOzhq2IUibdNdqJsUPgUaqGyrfB+eyYhoTVHY7kH5/EdXMnbzw4S7tRXb9/X0MImCzOsjLjT/GOpDazuJChokJ0mqFx/A9tNTpsJ8r3n+PyIsnCywPGtOM9X4u3j8pSY+miFoZMYExYKi+jZDU9uei1xcpna/PZwYku2B5XAcf8xndV"
  vpc_id = module.network.vpc_id
}

resource "aws_eip_association" "todo_ec2" {
  instance_id   = module.ec2.instance_id
  allocation_id = module.network.eip_id
}
