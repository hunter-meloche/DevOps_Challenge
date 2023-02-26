# IaC Challenge

A challenge set up to demonstrate Infrastructure as Code (IaC) knowledge by deploying an HTTPS-only nginx service with a self-signing SSL certificate into AWS using Docker, Bash, and Terraform.

## Prerequisites
```
AWS CLI
Terraform
Docker
Bash
```
### Instructions
After AWS CLI, Terraform, and Docker are all properly configured on your host running Bash, run build.sh to create the infrastructure. After setup is complete, test.sh will be automatically called to test what was provisioned. After that, destroy.sh can teaar down the infrastructure to avoid unnecessary costs.
