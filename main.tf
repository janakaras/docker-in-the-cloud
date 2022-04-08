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
  access_key = "ASIAZJERCJX3FSPDIMNK"
  secret_key = "Mp5eXj9TsxfWJI5HVAK4lBfV6DInbi6tQSC2UL6t"
  token = "FwoGZXIvYXdzEE8aDO2hDqcnI1orKFCkJSLSAXEXbSddCV1mV91pLBr6sT/2FT27tv12bdjC/UA76iYcy245sOYIKdpC7lQ89BWfaNKzwLXrAn5pmtIfmjDzMJ1CfeEuUnucxFZQkKa79MQOubO6h55Zagdrvf1NMtTIJKEPuWchvduda8EPQ1diOdz9fpCIP2oZ8X7hQE3izTDnAsm7v0T1P1DRp3TOg/BE4M5nGnuGbBULNaqS7QdGx9sSJOrV/a5IxmCSDjwY021OU+3VcmA06e0hXvTx4O12aW7BxEdJdpga1kkyUHqj/WTHQij5gMGSBjItzHQ/VuvaN/Mayoe9FXRsPBCc8T0Kyawus0ea82P0jJb3X5QDDk6SWWwwO82L"
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}




