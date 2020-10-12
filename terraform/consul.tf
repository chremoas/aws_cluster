//
// EC2 Consul server cluster
//
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

//
// ECS Consul clients
//
resource "aws_cloudwatch_log_group" "consul-client" {
  name = "/ecs/consul-client-shared"
}

data "template_file" "consul-config" {
  template = file("${path.module}/files/consul-client.json")

  vars = {
    tag_key = "ConsulDiscovery"
    tag_value = "consul-shared"
    datacenter = "consul-shared"
    aws_region = var.aws_region
    awslogs_group = "/ecs/consul-client-shared"
    awslogs_stream_prefix = "consul-client-shared"
    awslogs_region = var.aws_region
  }
}

resource "aws_ecs_task_definition" "consul-client" {
  family = "consul-client"
  container_definitions = data.template_file.consul-config.rendered

  network_mode = "host"

  task_role_arn = aws_iam_role.consul_client_autodiscovery.arn
}

resource "aws_ecs_service" "consul-client" {
  name = "consul-client"
  cluster = module.ecs_arm_cluster.cluster_id
  task_definition = aws_ecs_task_definition.consul-client.arn
  scheduling_strategy = "DAEMON"
}