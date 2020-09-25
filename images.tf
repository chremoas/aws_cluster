data "aws_ami" "AmazonLinux2-arm64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name = "architecture"
    values = ["arm64"]
  }

  owners      = ["137112412989"]
}

data "aws_ami" "AmazonLinux2-ECS-arm64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm*"]
  }

  filter {
    name = "architecture"
    values = ["arm64"]
  }

  owners      = ["591542846629"]
}