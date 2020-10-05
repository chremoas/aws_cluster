//module "bastion" {
//  source                 = "terraform-aws-modules/ec2-instance/aws"
//  version                = "~> 2.0"
//
//  name                   = "bastion"
//  instance_count         = 1
//
//  ami                    = data.aws_ami.AmazonLinux2-arm64.image_id
//  instance_type          = var.bastion_instance_type
//  key_name               = "aws_cluster"
//  monitoring             = false
//  vpc_security_group_ids = [module.bastion_sg.this_security_group_id]
//  subnet_id              = module.primary.public_subnets[0]
//
//  user_data = file("files/setup_proxy.sh")
//
//  tags = {
//    Terraform   = "true"
//    Environment = "dev"
//  }
//}
//
//module "bastion_sg" {
//  source = "terraform-aws-modules/security-group/aws//modules/ssh"
//
//  name        = "bastion-servers"
//  description = "Security group for bastion-servers with SSH ports open to Home"
//  vpc_id      = module.primary.vpc_id
//
//  ingress_cidr_blocks = ["75.52.174.32/29"]
//}
