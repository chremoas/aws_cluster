module "ecs_arm_cluster" {
//  source = "infrablocks/ecs-cluster/aws"
//  version = "~> 3.1"
//  source = "github.com/bhechinger/terraform-aws-ecs-cluster"
  source = "../../../terraform-aws-ecs-cluster"

  region = var.aws_region
  vpc_id = module.primary.vpc_id
  subnet_ids = module.primary.public_subnets
  cluster_instance_amis = { (var.aws_region) = data.aws_ami.AmazonLinux2-ECS-arm64.image_id}

  // Temporary for debugging
  cluster_instance_ssh_public_key_path = "/home/wonko/.ssh/aws_cluster.pub.pem"

  security_groups = [
    module.consul_shared.consul_security_group,
    module.consul_shared.ssh_security_group,
    aws_security_group.cluster_public.id
  ]

  component = "chremoas"
  deployment_identifier = "prod"

  cluster_name = "ARM_services"
  cluster_instance_type = var.ecs_arm_cluster_instance_type

  cluster_minimum_size = 2
  cluster_maximum_size = 4
  cluster_desired_capacity = 2

  target_group_arns = [
    aws_alb_target_group.quassel.arn,
    aws_alb_target_group.traefik-80.arn,
    aws_alb_target_group.traefik-443.arn,
    aws_alb_target_group.traefik-8080.arn
  ]
}

resource "aws_security_group" "cluster_public" {
  name = "cluster_public"
  vpc_id = module.primary.vpc_id
}

resource "aws_security_group_rule" "quassel-main" {
  from_port = 4242
  protocol = "tcp"
  security_group_id = aws_security_group.cluster_public.id
  to_port = 4242
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quassel-ident" {
  from_port = 113
  protocol = "tcp"
  security_group_id = aws_security_group.cluster_public.id
  to_port = 113
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "traefik-80" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.cluster_public.id
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "traefik-8080" {
  from_port = 8080
  protocol = "tcp"
  security_group_id = aws_security_group.cluster_public.id
  to_port = 8080
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "traefik-443" {
  from_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.cluster_public.id
  to_port = 443
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
