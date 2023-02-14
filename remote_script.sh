#!/bin/bash

# Extracts info from instance metadata
ACCOUNT_ID=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | \
  grep "accountId" | awk '{print $3}' | sed 's/"//g' | sed 's/,//g')
REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | \
  grep "region" | awk '{print $3}' | sed 's/"//g' | sed 's/,//g')
IP_ADDRESS=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

# Updates package repositories and installs openssl and docker
sudo yum update -y && sudo yum install -y openssl docker

# Create nginx directories and copy in config file
mkdir nginx_conf
mkdir nginx_conf/conf.d
cp /tmp/nginxDefault.conf $(pwd)/nginx_conf/default.conf

# Generates SSL cert for host's public IP to enable HTTPS
sudo openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout $(pwd)/nginx_conf/nginx-selfsigned.key \
  -out $(pwd)/nginx_conf/nginx-selfsigned.crt \
  -subj "/CN=$IP_ADDRESS"

sudo chown -R ec2-user:ec2-user nginx_conf

# Starts Docker service
sudo service docker start

# Connect Docker to ECR
aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Pulls nginx-test image from ECR and launches container
docker run -d -v $(pwd)/nginx_conf:/etc/nginx/conf.d -p 443:443 -p 80:80 --name nginx \
  $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/nginx-test
