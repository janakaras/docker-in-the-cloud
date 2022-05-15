terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  
  backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "test-organization-cloud-computing"
    
    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "docker-in-the-cloud"
    }
  }

  required_version = ">= 1.0.4"
}

provider "aws" {
  profile    = "default"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region     = "us-east-1"
}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 5001 # to be changed when application runs only from 5004
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 5004
    }
  ]
}

resource "aws_instance" "app_server" {
  count                  = 1
  ami                    = "ami-03ededff12e34e59e"
  instance_type          = "t2.micro"
  key_name               = "CC_UNI"
 vpc_security_group_ids = [aws_security_group.main.id]
 user_data = <<EOF
     #! /bin/bash
     sudo yum update -y
     sudo yum install docker -y
     sudo curl -L https://github.com/docker/compose/releases/download/1.29.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null
     sudo chmod +x /usr/local/bin/docker-compose
     sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose 
     EOF
  
  tags = {
     Name = "EC2-with-Security-Rule-Port-5004"
   }
  
  # user_data_replace_on_change = true



}

# ATTACH EXISTING IP 
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.app_server[0].id
  allocation_id = "eipalloc-02e80b7c8b21aac2d"
}

# PRINTS THE IP
output "ec2instance" {
  value = aws_instance.app_server[0].public_ip
}
