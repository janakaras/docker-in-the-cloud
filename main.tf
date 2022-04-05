terraform {
       backend "remote" {
              # The name of your Terraform Cloud organization.
              organization = "test-organization-cloud-computing"
              
              # The name of the Terraform Cloud workspace to store Terraform state files in.
              workspaces {
                     name = "docker-in-the-cloud"
              }
       }
       
       required_providers {
           aws = {
             source  = "hashicorp/aws"
             version = "~> 3.27"
           }
       }
       
       required_version = ">= 0.14.9"
}

# An example resource that does nothing.
resource "null_resource" "example" {
       triggers = {
              value = "A example resource that does absolutely nothing!"
       }
}

provider "aws" {
  access_key = "ASIAWEEGKEYJQ2BUANRI"
  secret_key = "SalIL4JmfZThTxswyKRpa2D8S4ReHRG/r7WQqZgi"
  token = "FwoGZXIvYXdzEAcaDKf2XnmDC1NUhdmWsyLNAS7DBH1rIWmbNg53sWV+uNwzPfee+xinLgVptCkdXNMbBaxFcnbkA8pjqZBj5ooltdvkIq8uZkfwtLjyj/iDPNtpNkm9FqZjOOT8uddIRQNHxR9XHQ7EQt8eQPL3zb3PNL5wHJyVGapwkaQkx0bKiZh2hitKxv1uB2EjfNU+xk8RoRo6NUAl2iYBOT4ST7aYBOZd2BGT5Sx2oAVgDmu7KYlL/SdZulh63RDDC7/1mYVI3F6ZSr1TuqTx9pxx2wMQOlOgf+M2XwKTYVBPMZIolYuxkgYyLbO6xsPj7LIsT1j06vssrZwjxuayEz7Yq3SSnw81i5tvw/QIqljWYM61ZBKnTg=="
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}




