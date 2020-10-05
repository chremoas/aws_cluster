resource "aws_instance" "consul_server" {
  count = var.servers
  ami = local.ami_id[var.architecture]
  instance_type = var.instance_type
  key_name = var.ssh_key_name
  iam_instance_profile = aws_iam_instance_profile.consul_autodiscovery.name

  vpc_security_group_ids = [
    module.ssh_sg.this_security_group_id,
    module.consul_sg.this_security_group_id
  ]

  user_data = data.template_file.config_script.rendered
  subnet_id = element(var.subnets, count.index)

  tags = {
    Name = "${var.cluster_name}-${count.index+1}"
    ConsulDiscovery = var.cluster_name
    Application = "consul"
    Terraform = "true"
    Environment = "shared"
  }
}

data "template_file" "config_script" {
  template = file("${path.module}/files/configure_consul.sh")
  vars = {
    datacenter = var.cluster_name
    leave_on_terminate = var.leave_on_terminate
    aws_region = var.aws_region,
    bootstrap_expect = var.servers,
    join_ec2_tag_key = "ConsulDiscovery",
    join_ec2_tag = var.cluster_name
  }
}

resource "aws_iam_role_policy" "consul_autodiscovery" {
  policy = data.aws_iam_policy_document.consul_autodiscovery.json
  role = aws_iam_role.consul_autodiscovery.id
}

data "aws_iam_policy_document" "consul_autodiscovery" {
  statement {
    effect = "Allow"
    actions = ["ec2:DescribeInstance*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "consul_autodiscovery" {
  name = "${var.cluster_name}-autodiscovery"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "${var.cluster_name}-autodiscovery"
    Application = "consul"
    Terraform = "true"
    Environment = "shared"
  }
}

resource "aws_iam_instance_profile" "consul_autodiscovery" {
  name = "${var.cluster_name}-autodiscovery"
  role = aws_iam_role.consul_autodiscovery.name
}

module "ssh_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "${var.cluster_name}-ssh"
  description = "Security group for consul servers with SSH ports"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.ssh_allowed_cidrs
}

module "consul_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "${var.cluster_name}-consul-ports"
  description = "Security group for consul servers with Consul ports"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.consul_allowed_cidrs
}
