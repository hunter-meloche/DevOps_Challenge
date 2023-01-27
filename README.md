# Hunter_Challenge

This challenge is composed of 2 parts: Infrastructure and Coding.

## Infrastructure
The goal with my approach to this was efficiency. I'm only using Docker, Terraform, and Bash.
### Docker
Docker is used to create an nginx container with a custom configuration for redirecting HTTP traffic to HTTPS, as well as generating a self-signed SSL certificate to facilitate HTTPS. The Hello World HTML page is also encoded within the Dockerfile to minimize the amount of files cluttering the repo.
### Terraform
I chose to use Terraform with AWS because it keeps the door open for additional monitoring (Cloudwatch, Kinesis->Splunk) and scalability (autoscaling policy, ECS, EKS). Firstly, a Security Group is created that only opens port 80 and 443 for ingress, and port 443 for egress. The ingress ports are needed to redirect HTTP (80) and facilitate HTTPS (443). The 443 egress port allows for the instance to updates its packages and retreive Docker. Then a lightweight EC2 instance is created that attaches to the Security Group. I encoded a Bash script into the User Data of the instance, so when the instance first boots the script will download Docker and launch the nginx container.
### Bash
I created three different Bash scripts in the root of the repository. They've been modularized, so they can be added for different stages of an automated pipeline, like Jenkins. The build.sh script builds and pushes the Docker image to Docker Hub, then creates the AWS infrasture with Terraform, and finally calls test.sh. The test script retrieves the public IP address of the instance and waits for the nginx container to start. Once the container is up, the script tests for HTTP->HTTPS redirection, HTTPS itself, and verifies that Hello World displays as expected. The final script, destroy.sh, tears down the AWS infrastructure with Terraform to avoid unnecessary costs.
## Coding
Regular expressions (regex) are used to verify that valid credit card numbers are submitted.

**"^[456][\d]{3}-?[\d]{4}-?[\d]{4}-?[\d]{4}$"**

'^' represents the start of the string

'[456]' matches the first digit of the string to be 4, 5, or 6

'[\d]{3}' matches the next three digits to be any digit (0-9)

'-?' matches zero or one occurrence of a hyphen

'[\d]{4}' matches the next four digits to be any digit (0-9)

'$' marks the end of the string

A second, smaller regex is used after the initial validation to account for groups of 4 sequential digits that may have been separated by commas.

**re.search(r"(\d)\1{3,}", cardNum.replace("-", ""))**

"(\d)\1" represents one digit followed by itself three more times "{3,}" AKA 4 consecutive digits and 
