terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  access_key = "ASIAWEEGKEYJZJAPPQ5N"
  secret_key = "TMpgjh3gUGmWHWT8dNt7l6WPFepoePTa6j6RMUp3"
  token      = "FwoGZXIvYXdzEFAaDI0h5bIIk0z1AthBhyLNAZPEWflTLlQAP9YJtSYupb87TF75pxNcWNtMXDpbB40jl41tAH1831mB7bvvPpV2Z0ojMAYKWoD+XygkR/Fj/ALTX9vuqLPpZcrkYNLkmjns2AicEfFqsOuGXyTtDNk34SpBtpQ1UZawvrhbcfRW65zCv9obqo4krVOfOlVkYaN1lr5BY4xjTc86PpCYS7V1WaWlGuJrfe2El5We8ikw330p+fQL4L9SoTFJfGF47VuVODM9doh6f5NKXyD5TyJxEc80GPYOoX7FG1TikDMoyY/BkgYyLW3DfpB6VsfzdHPSGjW1eI2+OFw1U6KT4jOGk8sqTE4BuoRoZ91mZWBOcYD8Dw=="
  region     = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

