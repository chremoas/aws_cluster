module "bastion" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "bastion"
  instance_count         = 1

  ami                    = data.aws_ami.AmazonLinux2-arm64.image_id
  instance_type          = var.bastion_instance_type
  key_name               = module.bastion_key_pair.this_key_pair_key_name
  monitoring             = false
  vpc_security_group_ids = [module.bastion_sg.this_security_group_id]
  subnet_id              = module.primary.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

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

module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "bastion-servers"
  description = "Security group for bastion-servers with SSH ports open to Home"
  vpc_id      = module.primary.vpc_id

  ingress_cidr_blocks = ["75.52.174.32/29"]
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "bastion_key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "bastion"
  public_key = tls_private_key.this.public_key_openssh
}