#!/bin/bash

# Start by building the Docker image and pushing it to Docker Hub
docker build -t hunter3035/challenge .
docker push hunter3035/challenge

# Initialize Terraform and build the AWS infrastructure
cd terraform
terraform init
terraform plan
terraform apply --auto-approve

# Call automated test script
cd ..
./test.sh
