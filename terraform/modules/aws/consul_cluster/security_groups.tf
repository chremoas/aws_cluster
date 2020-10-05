module "ssh_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "${var.cluster_name}-ssh"
  description = "Security group for consul servers with SSH ports"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.ssh_allowed_cidrs
}

module "consul_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/consul"

  name        = "${var.cluster_name}-consul-ports"
  description = "Security group for consul servers with Consul ports"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.consul_allowed_cidrs
}
