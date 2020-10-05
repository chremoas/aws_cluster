variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = {
    "arm64": "t4g.micro",
    "amd64": "t3.micro"
  }
}

//locals {
//  debian_ami_name = "${var.image_id}-debian"
//  foo             = "bar"
//}