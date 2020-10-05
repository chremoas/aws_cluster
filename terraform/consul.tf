module "consul_shared" {
  source = "./modules/aws/consul_cluster"
  cluster_name = "consul-shared"
  vpc_id = module.primary.vpc_id
  ssh_key_name = "aws_cluster"
  architecture = "arm64"
  ssh_allowed_cidrs = ["75.52.174.32/29", "10.0.0.0/16"]
  consul_allowed_cidrs = ["75.52.174.32/29", "10.0.0.0/16"]
  consul_version = "1.8.4"
  consul_template_version = "0.25.1"
  subnets = module.primary.public_subnets
  aws_region = var.aws_region
}
