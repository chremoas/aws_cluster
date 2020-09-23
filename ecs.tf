module "ecs_arm_cluster" {
  source = "infrablocks/ecs-cluster/aws"
  version = "~> 3.0"

  region = var.aws_region
  vpc_id = module.primary.vpc_id
  subnet_ids = module.primary.public_subnets
  cluster_instance_amis = { (var.aws_region) = data.aws_ami.AmazonLinux2-ECS-arm64.image_id}

  component = "chremoas"
  deployment_identifier = "prod"

  cluster_name = "ARM_services"
  cluster_instance_type = var.ecs_arm_cluster_instance_type

  cluster_minimum_size = 2
  cluster_maximum_size = 4
  cluster_desired_capacity = 2
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