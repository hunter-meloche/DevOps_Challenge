#!/bin/bash

# Start by creating the AWS infrastructure
cd terraform
terraform plan --destroy
terraform apply --destroy --auto-approve
