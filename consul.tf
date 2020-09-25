module "consul_shared" {
  source = "./modules/aws/consul_cluster"
  cluster_name = "consul-shared"
  vpc_id = module.primary.vpc_id
  ssh_key_name = "aws_cluster"
  ami = data.aws_ami.AmazonLinux2-arm64.image_id
  ssh_allowed_cidrs = ["75.52.174.32/29", "10.0.0.0/16"]
  consul_allowed_cidrs = ["75.52.174.32/29", "10.0.0.0/16"]
  consul_version = "1.8.4"
  consul_template_version = "0.25.1"
  subnets = module.primary.public_subnets
  aws_region = var.aws_region
}

//module "consul_cluster" {
//  source                 = "terraform-aws-modules/ec2-instance/aws"
//  version                = "~> 2.0"
//
//  name                   = "consul-cluster"
//  instance_count         = 3
//
//  ami                    = data.aws_ami.AmazonLinux2-arm64.image_id
//  instance_type          = var.consul_instance_type
//  key_name               = "aws_cluster"
//  monitoring             = false
//  vpc_security_group_ids = [module.consul_sg.this_security_group_id]
//  subnet_ids             = module.primary.private_subnets
//
//  tags = {
//    Application = "consul"
//    Terraform   = "true"
//    Environment = "shared"
//  }
//}
//
//module "consul_sg" {
//  source = "terraform-aws-modules/security-group/aws//modules/consul"
//
//  name        = "consul-servers"
//  description = "Security group for consul-servers with port 8500 open to Home"
//  vpc_id      = module.primary.vpc_id
//
//  ingress_cidr_blocks = ["75.52.174.32/29", "10.0.0.0/16"]
//}

//data "aws_vpc" "vpc" {
//  id = module.primary.vpc_id
//}
//
//data "template_file" "consul" {
//  template = file("${path.module}/files/consul.json")
//
//  vars = {
//    datacenter = coalesce(var.datacenter_name, data.aws_vpc.vpc.tags["Name"])
//    bootstrap_expect = 3
//    env = var.env
//    image = var.consul_image
//    aws_region = var.aws_region
//    node_name = "chremoas-consul"
//    consul_memory_reservation = var.consul_memory_reservation
//    s3_backup_bucket = var.s3_backup_bucket
//    join_ec2_tag_key = var.join_ec2_tag_key
//    join_ec2_tag = var.join_ec2_tag
//    awslogs_group = "consul-${var.env}"
//    awslogs_stream_prefix = "consul-${var.env}"
//    awslogs_region = var.region
//  }
//}
//
//resource "aws_ecs_task_definition" "consul" {
//  family                = "consul-${var.env}"
//  container_definitions = data.template_file.consul.rendered
//  task_role_arn         = aws_iam_role.consul_task.arn
//
//  volume {
//    name      = "docker-sock"
//    host_path = "/var/run/docker.sock"
//  }
//}
//
//resource "aws_cloudwatch_log_group" "consul" {
//  name              = aws_ecs_task_definition.consul.family
//  retention_in_days = var.cloudwatch_log_retention
//
//  tags = {
//    VPC         = data.aws_vpc.vpc.tags["Name"]
//    Application = aws_ecs_task_definition.consul.family
//  }
//}
//
//resource "aws_ecs_service" "consul" {
//  name                               = "consul-${var.env}"
//  cluster = module.ecs_arm_cluster.cluster_id
//  task_definition                    = aws_ecs_task_definition.consul.arn
//  desired_count                      = var.cluster_size
//  deployment_minimum_healthy_percent = var.service_minimum_healthy_percent
//
//  placement_constraints {
//    type = "distinctInstance"
//  }
//}
//