provider "aws" {
    region = "us-east-1"
}

# Security group with proper port configurations is created first
resource "aws_security_group" "challenge_sg" {
  name        = "challenge_sg"
  description = "security group for challenge"

  # Ingress port 443 for HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress port 80, so HTTP can be redirected to port 443
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress port 443, so repositories can be updated and dependencies can be fetched
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# An EC2 instance is used to host the nginx container
resource "aws_instance" "challenge_instance" {
    # Amazon Linux
    ami = "ami-0b5eea76982371e91"
    # Lightweight and free-tier instance
    instance_type = "t2.micro"
    # Security group is assigned
    vpc_security_group_ids = [aws_security_group.challenge_sg.id]

    # The name and description for the instance are assigned
    tags = {
            Name = "challenge"
            Description = "EC2 instance for challenge"
    }

    # On boot, the instance will run the following script
    # It installs Docker and runs the nginx container with the necessary ports
    user_data     = <<-EOF
                  #!/bin/bash
                  sudo yum update -y
                  sudo yum install -y docker
                  sudo service docker start
                  sudo docker run -d -p 443:443 -p 80:80 --name challenge hunter3035/challenge
                  EOF

}
