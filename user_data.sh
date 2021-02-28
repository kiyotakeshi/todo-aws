#!/bin/bash

yum update -y

yum install -y git
amazon-linux-extras install -y docker java-openjdk11

# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# docker engine start up
systemctl start docker
systemctl enable docker
