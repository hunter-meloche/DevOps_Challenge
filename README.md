# IaC Challenge

A challenge set up to Infrastructure as Code (IaC) knowledge.

## Prerequisites
```
aws-cli
terraform
docker
```
### Docker
Docker is used to create an nginx container that servers a simple Hello World page. The image is then sent to a private Elastic Container Registry (ECR) repository in AWS.
### Terraform
Terraform is used to create the AWS infrastructure that facilitates hosting the nginx container. The container runs on a free-tier EC2 instance running Amazon Linux 2. The instance is assigned a security group that only allows for the necessary ports to be opened. IAM roles and policies work together to allow the EC2 instance to pull the custom nginx Docker image from ECR. Of course, an ECR repository is created to store the image. Each component is modularized into its own .tf file. Upon the EC2 instance's creation, it runs the necessary scripts through user_data and remote_exec to set up and run the nginx container. A self-signed SSL certificate is generated to enable HTTPS and there is a custom configuration file for nginx to redirect all HTTP traffic to HTTPS.
### Bash
I created three different Bash scripts in the root of the repository. The build.sh script is ideally all you need to use if you've already set up the prereqs. It automatically calls test.sh to verify the deployment was successful. When you're done, you just need to call destroy.sh to clean up.

## Regex Coding Challenge
Regular expressions (regex) are used to verify that valid credit card numbers are submitted.
```
"^[456][\d]{3}-?[\d]{4}-?[\d]{4}-?[\d]{4}$"
```
'^' represents the start of the string

'[456]' matches the first digit of the string to be 4, 5, or 6

'[\d]{3}' matches the next three digits to be any digit (0-9)

'-?' matches zero or one occurrence of a hyphen

'[\d]{4}' matches the next four digits to be any digit (0-9)

'$' marks the end of the string

**A second, smaller regex is used after the initial validation to account for groups of 4 sequential digits that may have been separated by commas.**
```
re.search(r"(\d)\1{3,}", cardNum.replace("-", ""))
```
"(\d)\1" represents one digit followed by itself three more times "{3,}" AKA 4 consecutive digits.
