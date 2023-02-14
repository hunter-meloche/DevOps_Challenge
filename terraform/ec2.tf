# Pulls in pre-generated SSH key
resource "aws_key_pair" "mykey" {
  key_name = "mykey"
  public_key = "${file("../mykey.pem.pub")}"
}

# An EC2 instance is used to host the nginx container
resource "aws_instance" "nginx_instance" {
    # Amazon Linux
    ami = "ami-0b5eea76982371e91"
    # Lightweight and free-tier instance
    instance_type = "t2.micro"
    # Security group is assigned
    vpc_security_group_ids = [aws_security_group.nginx_sg.id]
    # Instance profile for ECR access
    iam_instance_profile = aws_iam_instance_profile.ecr_puller.name
    # Locally generated SSH key
    key_name = "${aws_key_pair.mykey.key_name}"

    # The name and description for the instance are assigned
    tags = {
            Name = "nginx"
            Description = "EC2 instance for nginx"
    }

    # Script that will activate inside of the instance
    provisioner "file" {
      source = "../remote_script.sh"
      destination = "/tmp/remote_script.sh"
    }

    # Config file for nginx service
    provisioner "file" {
      source = "../nginxDefault.conf"
      destination = "/tmp/nginxDefault.conf"
    }

    # Remote execution of the script
    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/remote_script.sh",
        "sudo /tmp/remote_script.sh"
      ]
    }

    # SSH connection to instance
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = "${file("../mykey.pem")}"
    }

    user_data = <<-EOF
    #!/bin/bash
    groupadd docker
    usermod -aG docker ec2-user
    EOF
}

# Saves the public IP of the instance
output "nginx_instance_public_ip" {
  value = aws_instance.nginx_instance.public_ip
}
