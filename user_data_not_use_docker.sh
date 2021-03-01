#!/bin/bash

yum update -y

yum install -y git postgresql-server
amazon-linux-extras install -y nginx1 java-openjdk11 postgresql11

/usr/bin/postgresql-setup --initdb

systemctl start postgresql
systemctl enable postgresql

# make reverse proxy conf
cat > /etc/nginx/default.d/reverse_proxy.conf <<EOF
location / {
    proxy_pass http://localhost:8081/;
    proxy_redirect off;
}
EOF

# docker engine start up
systemctl start nginx
systemctl enable nginx
