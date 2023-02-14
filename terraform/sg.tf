variable "local_ip" {
  type = string
}

# Security group with proper port configurations is created first
resource "aws_security_group" "nginx_sg" {
  name        = "nginx_sg"
  description = "security group for nginx"

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

  # Ingress port 22 for your IP so you can upload remote_script.sh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.local_ip}/32"]
  }

  # Egress port 443, so repositories can be updated and dependencies can be fetched
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
