terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.63.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "build" {
  ami = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.all.id]
  user_data = <<-EOL
  #!/bin/bash
  apt update
  apt install default-jdk -y
  apt install maven -y
  git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git /home
  mvn package -f /home/

  EOL
  
  tags = {
    Name = "build-server"
  }
}

resource "aws_instance" "web" {
  ami = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.all.id]
  user_data = <<-EOL
  #!/bin/bash
  apt update
  apt install default-jdk -y
  apt install tomcat9 -y
  
  EOL
  
  tags = {
    Name = "build-server"
  }
}

resource "aws_security_group" "all" {
  name        = "all"
  description = "all"

  ingress {
      description      = "http"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "all"
  }
}

output "instance_public_ip" {
  description = "IP address build"
  value       = aws_instance.build.public_ip
}

output "instance_public_ip" {
  description = "IP address web"
  value       = aws_instance.web.public_ip
}