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
  access_key = "ASIAWEEGKEYJS5VJ4LPS"
  secret_key = "K+e7lnUrS3dTi/QqWndtq8U/C+A68WBtEoVPMU7P"
  token      = "FwoGZXIvYXdzEK3//////////wEaDKHCHsKKP6lgmSg1xSLNAUuACp3o/nJWM2sca4sE5tPuZgFSbVAPUK6fjvlQqcU01uVFWE5hxSAPfQyceO7K3WHmT+xtNRDGETXdJDKqnWK2mVKwKD0zhOTLBExCf4M33g/z9CnCbyTcAik6SeV84/Cwl1P+cDtfhX80fqJIkVJtx5CQ9KMsSkC3j0I9zAnZd8f7BiWUqUtSczzaanYZIPMa3YBhbtBlKxiDG5tx062rqEDK6pRSbGzsuf0i3KW/Svt6Oid+YF2XOzzWnX7LftjJFyKEHV3Ho0okFSMoscjVkgYyLf4Oj/bLd8GlpQmv60snlVh3hgSNUwXsU5xTBlo6Atp+ywEDKm469Lgly1vsqQ=="
  region     = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

