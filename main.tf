#terraform {
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 3.27"
#    }
#  }
#
#  required_version = ">= 0.14.9"
#}

#provider "aws" {
#  access_key = "ASIAWEEGKEYJXE3PFRVK"
#  secret_key = "uehQWsBjtsci4kroW3F9vdz4sQB2aAsT50+MuJRV"
#  token      = "FwoGZXIvYXdzEFAaDOJqSKAUjZmdkrj+miLNASe59qSPzSaOurWJgBI7Q/fRwOy/gctBySmyOokepK0TqK1wxH2f+5g1kKe6J0GN+YmaslO8IzTPFQRH4OIZ4H5h8DUC4O+t6LF+WG/3E46pg5fprsFmTI4lhY280gA2ZfqdQYmMY3ZKcKuNbFlYx8CEPedehvrosiesiUR7pJbmTN/T4Xu6TliL1ZLurACvaSuwY99+mvu1dAR2qASp0LIl9VE/NoaUEwSyE9NLb7dbhrZYWGmu93wGgrk0I3rW0+xgTod5AZvQoPfFfKEouL35kgYyLWRI0xFpLQCUTSgpRIVbeUiAVLAQFB/uY5HbExllBcUoybPBwaFxytzp+8JHDA=="
#  region     = "us-east-1"
#}
#
#resource "aws_instance" "app_server" {
#  ami           = "ami-0c02fb55956c7d316"
#  instance_type = "t2.micro"
#
#  tags = {
#    Name = "ExampleAppServerInstance"
#  }
#}

# -----------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.0.4"
}

provider "aws" {
  profile    = "default"
  access_key = "ASIAWEEGKEYJXE3PFRVK"
  secret_key = "uehQWsBjtsci4kroW3F9vdz4sQB2aAsT50+MuJRV"
  token      = "FwoGZXIvYXdzEFAaDOJqSKAUjZmdkrj+miLNASe59qSPzSaOurWJgBI7Q/fRwOy/gctBySmyOokepK0TqK1wxH2f+5g1kKe6J0GN+YmaslO8IzTPFQRH4OIZ4H5h8DUC4O+t6LF+WG/3E46pg5fprsFmTI4lhY280gA2ZfqdQYmMY3ZKcKuNbFlYx8CEPedehvrosiesiUR7pJbmTN/T4Xu6TliL1ZLurACvaSuwY99+mvu1dAR2qASp0LIl9VE/NoaUEwSyE9NLb7dbhrZYWGmu93wGgrk0I3rW0+xgTod5AZvQoPfFfKEouL35kgYyLWRI0xFpLQCUTSgpRIVbeUiAVLAQFB/uY5HbExllBcUoybPBwaFxytzp+8JHDA=="
  region     = "us-east-1"
}

resource "aws_instance" "app_server" {
  count                  = 1
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  key_name               = "ec2-deployer-key-pair"
  vpc_security_group_ids = [aws_security_group.main.id]

  provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
  }
  tags = {
    Name = "EC2-with-Security-Rule-Port-5004"
  }
  connection {
    type    = "ssh"
    host    = self.public_ip
    user    = "ec2-user"
    timeout = "4m"
  }

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
      from_port        = 5004
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 5004
    }
  ]
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-deployer-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFAJSxi66GyyXma8eNGfq28OGVgFnOvF8TYxtu770wjU95HmRQLoWOKKunYofU4EdP7YvwV9bl1NjJAkvZ3bN+nWGxp1cNHTqfJDoyFlN8j1xnEFZdkzW74k2RpEb52vYSaHRizT7sqq/XuTK5MNcbbsTXvT6wiJpUkaberi4VBeD2wDzkLWjVHfMTfvs6/4vYuVML+7qfq6OMFYFWdFyRZ26w6KGHzKqLbUwC2waaetooNCtYQdyvcs2zYOulTeJDP49jYxrRRfpzJLqkxkdC96klIDmJRuujaBv3NWkGM1Xd7KvMUstI7NASZFd9O8ryVfHr2sO4MSWZ+jCHnLd6YiXL7dTlOJ+KZ7RiFboYD/7SxwuUFtAmFYn5Net3FmyVFZTAyujDpX8jQ9lfPuoee+J4dAlDvqSGsASxvyOMML2/VsxjXoS6YTLH76RZmkPswnYikm9R6/TsbFnOg2cgTADKpggD0O7I9CjFV9Xn1D/8qWEKqlX1eUIKzNO4Pt+iCSacS4GpTykinf/xyDXQ+di0K+rdSsWUe3x9AY2mJHbCSqKimSdZKT18kE6REly1qdX0WjmN+fqP5j9brXy7aJKUsCjSJPgzyAEjwo59hFYNjFJynWFxQPrdmIMoomg7Spk7FeAUL1C4VamHW9XptxZx+tdSVaL6mNrrYC1LBQ== jkaras@unibz.it"
}

