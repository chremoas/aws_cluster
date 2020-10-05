locals {
  ami_id = {
    "amd64": data.aws_ami.consul-server-amd64.image_id,
    "arm64": data.aws_ami.consul-server-arm64.image_id
  }
}

data "aws_ami" "consul-server-arm64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["consul-server-*"]
  }

  filter {
    name = "architecture"
    values = ["arm64"]
  }

  owners      = ["902392440299"]
}

data "aws_ami" "consul-server-amd64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["consul-server-*"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  owners      = ["902392440299"]
}
