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
  access_key = "ASIAUCTPCZ2QDBPN3ZHW"
  secret_key = "h+CX5ADUe6ZAyHXWsuq+YfEfPgu28YOzSjO62Rle"
  token      = "FwoGZXIvYXdzEHAaDMLQ7vXjYiaiUkNNICLTAe/Wb6a2pc7G+VulZkcVH/6/07dfxjWSVNHNdRnLbboSZHsYh5aynqxFa4tkf/NNzSKQAIdupN7+nvNNaWo7OWFMwlrrJNYr3H1fY2sKnjQtsyfCSGYQ6+vj0n0G5HyfNLDJzBL4aE9+fTF+ANqIcJ6S4xnsExLuu1yKbmzYzFdUETN2bA61eQJxhNh8GWL4fa5jt5piyuuo66Evb5MuLPb8ALjr5aR4JEPPWJeCoLM9uDW+9ejv67mp2GAkP1asrvxUV/pmk4uK4Rmje5My3aMR9ZUok7yAkwYyLUwvxLOqV3/j4en2H8qpOJWtzUVw9qMH+f7PUAhTNayKLUZLDE+tKqHC73qx9w=="
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
#  key_name               = "ec2-deployer-key-pair"
#  key_name = "github-actions"
 vpc_security_group_ids = [aws_security_group.main.id]
 user_data = <<EOF
     #! /bin/bash
     sudo wget https://github.com/janakaras/docker-in-the-cloud/archive/refs/heads/main.zip
     sudo unzip main.zip
     cd docker-in-the-cloud-main
     sudo yum update -y
     sudo yum install docker -y
     sudo curl -L https://github.com/docker/compose/releases/download/1.29.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null
     sudo chmod +x /usr/local/bin/docker-compose
     sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose 
     sudo service docker start
     sudo docker-compose up
#      sudo yum -y install httpd
#      sudo systemctl enable httpd
#      sudo systemctl start httpd
#      sudo echo '<html><h1>Hello From Your Web Server!</h1></html>' > /var/www/html/index.html
#     sudo yum install git -y
#     sudo git clone git@github.com:janakaras/docker-in-the-cloud.git
#     cd docker-in-the-cloud 
#     sudo docker-compose up
     EOF
  
  tags = {
     Name = "EC2-with-Security-Rule-Port-5004"
   }

#   provisioner "remote-exec" {
#     inline = [
#       "touch hello.txt",
#       "echo helloworld remote provisioner >> hello.txt",
#     ]
#   }

#   connection {
#     type    = "ssh"
#     host    = self.public_ip
#     user    = "ec2-user"
# # #   private_key = "b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcnNhAAAAAwEAAQAAAYEAz1zNPgtSKTeWPrMaxlBybesZ+3yikDcHe9cJUaEvhUB8x05ihhsAuy9DpOJKdQdZ/5k++b7gU6Wa+FrO/5uPMyhDtbEMAbZjlwaIgLiUSaJVe8byq6HXuDwmVqtWX4geMOVORQzpbC7OhDUdKB7RADiS5t+8eLDDhrYj5ejeNCMvniHGK6SXgLsleOuyoG0E4UfroO9+D6NKHkGGH+D/hKUiUPPaFLg1QxJ9XeFu3MpIdx8WQHIbX2QdOEBSoWlnfXzq8icKnAN8+3MSRNiw4YCEb9jze0v/NLPKYawvkhfSNsKbLhYNmK/5Tcn2Vyli8EcPbhDegK4zmAC+IBlIWAZaZZvQdnKHLTKTAOqCX5Al3BoRBwl8dFVxnnOlXKwBhTFAYxNpSHVLIJ30F93JtiKBuEWMi1gPPtZp1zbbfCnLgLmpuOyKjCB3Ke/6L5a3P6DSHwqzQoxXDrCqpete+Oeef5e6RlvPklY2r1rdTX/Zeth+siycVRYh+ocw6yjnAAAFkCqTNBkqkzQZAAAAB3NzaC1yc2EAAAGBAM9czT4LUik3lj6zGsZQcm3rGft8opA3B3vXCVGhL4VAfMdOYoYbALsvQ6TiSnUHWf+ZPvm+4FOlmvhazv+bjzMoQ7WxDAG2Y5cGiIC4lEmiVXvG8quh17g8JlarVl+IHjDlTkUM6WwuzoQ1HSge0QA4kubfvHiww4a2I+Xo3jQjL54hxiukl4C7JXjrsqBtBOFH66Dvfg+jSh5Bhh/g/4SlIlDz2hS4NUMSfV3hbtzKSHcfFkByG19kHThAUqFpZ3186vInCpwDfPtzEkTYsOGAhG/Y83tL/zSzymGsL5IX0jbCmy4WDZiv+U3J9lcpYvBHD24Q3oCuM5gAviAZSFgGWmWb0HZyhy0ykwDqgl+QJdwaEQcJfHRVcZ5zpVysAYUxQGMTaUh1SyCd9BfdybYigbhFjItYDz7Wadc223wpy4C5qbjsiowgdynv+i+Wtz+g0h8Ks0KMVw6wqqXrXvjnnn+XukZbz5JWNq9a3U1/2XrYfrIsnFUWIfqHMOso5wAAAAMBAAEAAAGBAMXxcHqpk+SEi4eOsSBd6t3CbysB7qx720j8HIkvtI0e4f3fdW1OmYQVuhzLZwgP3HmBb/w3mSxACY7KII8fj7Ll3Ly0JSH9WVPxiJxXljY0ICXn4/6yn5ne0ToqlGjdJvTF79E6YhhDFiBeE1cZE6mCV7jMGr2a/wq5E8uEX5ilfe8VjnZax8S64Sps1DcP2niyjtsxwsRqu3XmVoJX5ZJZkEh2ftcIgM9l9waHC6z36/TKWBNs2XRVvQ7VWAt88PVSHWXFHo4ocHnoAUkg2IruFbEETUyfO/UlOE65cmNIqTwqpDJwbFx6xP40k3SzUAL58g4z97dzYqcGluKodWaL+yiIvq+I7KJyhyYicpsTna2oYcRRRZ1Yf8N6e/FCGNDub1fjKkXZaAzbisC57R5WDFTrb31qylT35+4rbEAR1Alt8LgwkqNjoRGic0zjjozlSy+kCtKPn4UUfwq6grbWRe6n+C5i7yGfMnoeqq0KIZw/I3tbrB0ID9q2d/pLAQAAAMEA5H1suyzGK2ygxhzCct/4/XOgjLpE4t3crCfp6HLnIhGtdVnOkr98a4//67Hs27jIs1FAJdwOAJmnI8YabUVGr1y0IiD6Uz+NA3rey7yto8byuJCJItix58a4Fwqcs1DURfdh8V6tlInRy0+ae4D0YPr8LUpi1oUsyWFLD3kai46Ox6SL0IoXeYf52+ume63ZHyw+Ri9aVNtbPvCvNrBJHcFAC/z4fPjRxVFoiGzlyqmlOLKzV3O8zXdCzXrlKNBaAAAAwQDusRZmCTHT95JNUl5yUlJtuJwYwWzLoWftaefstLpjo9ACpAJ6Lihasz9PKrxmn+xq/kYaGYbEbPS6+SaCddyEbnrggfZhm9M8t5jgO8FJ0Fc4kLInDdg1UO0nFgggJ3kNhcY4HegO+InUO+gVPN1jOAOHgkeRXpSajyT3JzA7yj9453uJ/YDC9gdpKPq6lasgglOqfTmbqgS0qdLWOsSkysqLVB0B/rBTb/hYZlMqbuiI1o3tBKte4PL1isDJP4sAAADBAN5mI6wOo6tXN2e1m6h7flrfvL0fptRpNrAKc5g/3dIoAi8P7dRtVawVeChKCfms7h1FsEiuHpiXkDQzus1vuttQPRAE3vU/3lHG4vruSvtFy32rF3UNimPSPvNDsG/81Ny7Dwciip2lbChbqjVqp5vXEbjZgyPFEZ+vpVuYZlOhVKjgejzwkLWx0RcOeW+sNnsX2R2Kv3wWXUQ1Ll61p501lwtA96jRzivagc3qTmCoH8xKv20IWkW9k7SwrLEnlQAAABdqb2huZG9lQERFU0tUT1AtRVBFUVQ1RAEC"
#     timeout = "4m"
#   }

}

# PRINTS THE IP
output "ec2instance" {
  value = aws_instance.app_server[0].public_ip
}

#  resource "aws_key_pair" "deployer" {
#  #  key_name   = "ec2-deployer-key-pair"
#    key_name = "github-actions"
#  #  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFAJSxi66GyyXma8eNGfq28OGVgFnOvF8TYxtu770wjU95HmRQLoWOKKunYofU4EdP7YvwV9bl1NjJAkvZ3bN+nWGxp1cNHTqfJDoyFlN8j1xnEFZdkzW74k2RpEb52vYSaHRizT7sqq/XuTK5MNcbbsTXvT6wiJpUkaberi4VBeD2wDzkLWjVHfMTfvs6/4vYuVML+7qfq6OMFYFWdFyRZ26w6KGHzKqLbUwC2waaetooNCtYQdyvcs2zYOulTeJDP49jYxrRRfpzJLqkxkdC96klIDmJRuujaBv3NWkGM1Xd7KvMUstI7NASZFd9O8ryVfHr2sO4MSWZ+jCHnLd6YiXL7dTlOJ+KZ7RiFboYD/7SxwuUFtAmFYn5Net3FmyVFZTAyujDpX8jQ9lfPuoee+J4dAlDvqSGsASxvyOMML2/VsxjXoS6YTLH76RZmkPswnYikm9R6/TsbFnOg2cgTADKpggD0O7I9CjFV9Xn1D/8qWEKqlX1eUIKzNO4Pt+iCSacS4GpTykinf/xyDXQ+di0K+rdSsWUe3x9AY2mJHbCSqKimSdZKT18kE6REly1qdX0WjmN+fqP5j9brXy7aJKUsCjSJPgzyAEjwo59hFYNjFJynWFxQPrdmIMoomg7Spk7FeAUL1C4VamHW9XptxZx+tdSVaL6mNrrYC1LBQ== jkaras@unibz.it"
#    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPXM0+C1IpN5Y+sxrGUHJt6xn7fKKQNwd71wlRoS+FQHzHTmKGGwC7L0Ok4kp1B1n/mT75vuBTpZr4Ws7/m48zKEO1sQwBtmOXBoiAuJRJolV7xvKrode4PCZWq1ZfiB4w5U5FDOlsLs6ENR0oHtEAOJLm37x4sMOGtiPl6N40Iy+eIcYrpJeAuyV467KgbQThR+ug734Po0oeQYYf4P+EpSJQ89oUuDVDEn1d4W7cykh3HxZAchtfZB04QFKhaWd9fOryJwqcA3z7cxJE2LDhgIRv2PN7S/80s8phrC+SF9I2wpsuFg2Yr/lNyfZXKWLwRw9uEN6ArjOYAL4gGUhYBlplm9B2coctMpMA6oJfkCXcGhEHCXx0VXGec6VcrAGFMUBjE2lIdUsgnfQX3cm2IoG4RYyLWA8+1mnXNtt8KcuAuam47IqMIHcp7/ovlrc/oNIfCrNCjFcOsKql6174555/l7pGW8+SVjavWt1Nf9l62H6yLJxVFiH6hzDrKOc= johndoe@DESKTOP-EPEQT5D"
  
# }
