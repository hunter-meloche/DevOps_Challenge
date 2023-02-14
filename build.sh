#!/bin/bash

# Gets your IP address for SSH connection to EC2 instance
YOUR_IP=$(curl checkip.amazonaws.com)

# Gets AWS account and region info from aws-cli
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION=$(aws configure get region)

# Generates SSH key to login to EC2 instance, unless it exists already
if [ ! -f mykey.pem ]; then
  ssh-keygen -t rsa -f mykey.pem -N ""
fi

# Authenticates with ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS \
  --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Builds and tags nginx-test image to be uploaded to ECR repo in AWS
docker build -t nginx-test .
docker tag nginx-test:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/nginx-test

# Overwrites provider.tf with your AWS region info
cd terraform
echo "provider "aws" {
  region = "\"$AWS_REGION\""
}" > provider.tf

# Passes your local IP as a tfvars variable
echo "local_ip = \"$YOUR_IP\"" > terraform.tfvars

# Initialize Terraform and create the ECR repo
terraform init
terraform plan
terraform apply -target=aws_ecr_repository.nginx_test --auto-approve

# Push the nginx-test image to the ECR repo
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/nginx-test

# Initialize Terraform and build the AWS infrastructure
terraform plan
terraform apply --auto-approve

# Extracts instance's public IP from terraform
INSTANCE_IP=$(terraform output | awk '{print $3}' | sed 's/"//g')

# Calls test script and passes the IP of the instance
cd ..
./test.sh $INSTANCE_IP
