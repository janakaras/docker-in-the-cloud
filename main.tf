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
  ami                    = "ami-03ededff12e34e59e"
  instance_type          = "t2.micro"
  key_name               = "ec2-deployer-key-pair"
#  key_name = "Github_SSH_key"
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
#  key_name = "Github_SSH_key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOsJr1/n7xHmlMNnTok15a0DwX6tSbBet5qpBPbYOB6S jana.karas@gmx.de"
}

