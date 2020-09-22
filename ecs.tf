module "ecs_arm_cluster" {
  source = "infrablocks/ecs-cluster/aws"
  version = "~> 3.0"

  region = var.aws_region
  vpc_id = module.primary.vpc_id
  subnet_ids = module.primary.public_subnets
  cluster_instance_amis = { us-east-1 = data.aws_ami.AmazonLinux2-arm64.image_id}

  component = "chremoas"
  deployment_identifier = "prod"

  cluster_name = "ARM_services"
//  cluster_instance_ssh_public_key_path = "~/.ssh/ew_rsa.pub"
  cluster_instance_type = var.ecs_arm_cluster_instance_type

  cluster_minimum_size = 1
  cluster_maximum_size = 4
  cluster_desired_capacity = 2
}