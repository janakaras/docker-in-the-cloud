# An example resource that does nothing.

terraform {
 required_providers {
  null = {
   version = "~> 3.0.0"
  }
 }
}


resource "null_resource" "example" {
 triggers = {
  value = "A example resource that does nothing!"
 }
}

