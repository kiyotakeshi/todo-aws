# Todo AWS

## Requirement

- awscli

- tfenv

- terraform

- wget

---
## Operate AWS Component

- create s3 bucket

```shell
export YOUR_BUCKET_NAME="kiyotake-todo-terraform"

aws s3api create-bucket --bucket $YOUR_BUCKET_NAME --region ap-northeast-1 --create-bucket-configuration LocationConstraint=ap-northeast-1

$ aws s3 ls | grep $YOUR_BUCKET_NAME
2021-02-28 19:51:22 kiyotake-todo-terraform

aws s3api put-bucket-versioning --bucket $YOUR_BUCKET_NAME --versioning-configuration Status=Enabled

aws s3api get-bucket-versioning --bucket $YOUR_BUCKET_NAME

# 削除
# aws s3api delete-bucket --bucket $YOUR_BUCKET_NAME --region ap-northeast-1 
```

- set config.tf bucket name

```shell
sed -ie "s/kiyotake-todo-terraform/$YOUR_BUCKET_NAME/g" config.tf
```

- set terraform execute environment

```shell
tfenv install 0.14.7

tfenv use 0.14.7

$ terraform --version
Terraform v0.14.7
```

- set AWS credentials
    - create IAM User in advance

```shell
export AWS_ACCESS_KEY_ID="ABCDEFGHIJKLMNOPQRST"
export AWS_SECRET_ACCESS_KEY="ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMN"
```

- create ssh key pair

```shell
ssh-keygen -m PEM -t rsa -b 2048 -f todo_key -C ""

# using .pub key in main.tf
$ ls todo_key*
todo_key	todo_key.pub
```

### Create

```shell
terraform init

terraform plan

terraform apply
```

※ If you want to check tfstate file

```shell
terraform state pull > /tmp/todo-terraform-tfstate.json
```

### Connect EC2

- [Using Session Manager over SSH](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html)
    - [@see install Session Manager plugin](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
    - [@see sessions start ssh](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html#sessions-start-ssh)

- following steps are to install for `Mac`
    
```shell
# add ssh config
cat >> ~/.ssh/config << EOF
# SSH over Session Manager
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
EOF

curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"

unzip sessionmanager-bundle.zip

sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin

./sessionmanager-bundle/install -h
```

- connect to EC2 using Session Manager over SSH

```shell
$ terraform output instance_id
"i-0abcdefg12345hijk"

$ file todo_key
todo_key: PEM RSA private key

chmod 400 todo_key

export AWS_DEFAULT_REGION="ap-northeast-1"

export AWS_ACCESS_KEY_ID="ABCDEFGHIJKLMNOPQRST"

export AWS_SECRET_ACCESS_KEY="ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMN"

ssh -i todo_key ec2-user@i-0abcdefg12345hijk
```

- if you can connect EC2 

```
       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
-bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
[ec2-user@ip-172-31-0-140 ~]$
```

### Deploy Todo application (nginx and embedded tomcat jar)

**user_data = file("./user_data_not_use_docker.sh")** case.

- confirm user data script executed expectedly

```shell
sudo su -

# systemctl is-active postgresql
active

# systemctl is-enabled postgresql
enabled

# systemctl is-active nginx
active

# systemctl is-enabled nginx
enabled

# cat /etc/nginx/default.d/reverse_proxy.conf
location / {
    proxy_pass http://localhost:8081/;
    proxy_redirect off;
}

# git --version
git version 2.23.3

# java -version
openjdk version "11.0.9" 2020-10-20 LTS

# psql --version
psql (PostgreSQL) 11.5
```

- create Database and set password

```shell
su - postgres

psql

create database todo;

alter user postgres with password 'password';

\l
```

- パスワード認証 (md5) に変更 

```shell
cp /var/lib/pgsql/data/pg_hba.conf{,.org}

# ls /var/lib/pgsql/data/pg_hba.conf*
/var/lib/pgsql/data/pg_hba.conf  /var/lib/pgsql/data/pg_hba.conf.org

vi /var/lib/pgsql/data/pg_hba.conf

# diff /var/lib/pgsql/data/pg_hba.conf.org /var/lib/pgsql/data/pg_hba.conf

82c82
< host    all             all             127.0.0.1/32            ident
---
> host    all             all             127.0.0.1/32            md5
```

- build spring app

```shell
git clone https://github.com/kiyotakeshi/todo.git && cd todo
```

```shell
# curl inet-ip.info
35.72.190.25

vi src/main/java/com/kiyotakeshi/todo/controller/TodoApiController.java
```

```java
@CrossOrigin(origins = {"http://35.72.190.25"})
 public class TodoApiController {
```

```shell
./mvnw clean package

nohup java -jar target/todo-*.jar &

# ps auxwww | grep java | grep -v grep
root      5727 19.0  9.5 2755576 193716 pts/0  Sl   16:12   0:15 java -jar target/todo-1.1.0.jar

# netstat -anp | grep java | grep 8081
tcp6       0      0 :::8081                 :::*                    LISTEN      5727/java
```

### Deploy Todo application (As a Docker container)

**instance_type = "t2.small"** and **user_data = file("./user_data.sh")** case.

- confirm user data script executed expectedly

```shell
sudo su -

# systemctl is-active docker
active

# systemctl is-enabled docker
enabled

# docker-compose --version
docker-compose version 1.28.4, build cabd5cfb

# git --version
git version 2.23.3

# java -version
openjdk version "11.0.9" 2020-10-20 LTS
```

- build spring app and nginx docker image

```shell
git clone https://github.com/kiyotakeshi/todo.git && cd todo 
```

```shell
# curl inet-ip.info
35.72.190.25

vi src/main/java/com/kiyotakeshi/todo/controller/TodoApiController.java
```

```java
@CrossOrigin(origins = {"http://35.72.190.25"})
 public class TodoApiController {
```

```shell
./mvnw spring-boot:build-image

export ARTIFACT_VERSION=$(ls target/todo-*.jar | awk -F "-" '{print $2}' | cut -b -5) && echo $ARTIFACT_VERSION

docker-compose -f app.yaml build
```

- run the containers

```shell
docker-compose -f app.yaml up -d

docker-compose -f app.yaml ps

docker-compose -f app.yaml logs
```

### Access by browser

- following case, http://35.72.190.25

```shell
# curl inet-ip.info
35.72.190.25
```

### Delete

```shell
terraform destroy
```

or, comment out main.tf and related file and ...

```shell
terraform apply
```

```
Destroy complete! Resources: 18 destroyed.
```