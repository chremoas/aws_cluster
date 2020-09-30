resource "aws_instance" "consul_server" {
  count = var.servers
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.ssh_key_name

  vpc_security_group_ids = [
    module.ssh_sg.this_security_group_id,
    module.consul_sg.this_security_group_id
  ]

  user_data_base64 = data.template_cloudinit_config.config.rendered
  subnet_id = element(var.subnets, count.index)

  tags = {
    Name = "${var.cluster_name}-${count.index+1}"
    ConsulDiscovery = var.cluster_name
    Application = "consul"
    Terraform = "true"
    Environment = "shared"
  }
}

data "template_file" "install_script" {
  template = file("${path.module}/files/install_consul.sh")

  vars = {
    CONSUL_VERSION = var.consul_version,
    CONSUL_TEMPLATE_VERSION = var.consul_template_version,
  }
}

data "template_file" "consul_config" {
  template = file("${path.module}/files/consul_config.hcl")
  vars = {
    datacenter = var.cluster_name
    leave_on_terminate = var.leave_on_terminate
    aws_region = var.aws_region,
    bootstrap_expect = var.servers,
    join_ec2_tag_key = "ConsulDiscovery",
    join_ec2_tag = var.cluster_name
  }
}

data "template_cloudinit_config" "config" {
  gzip = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = "mkdir -p /opt/consul/data && mkdir -p /opt/consul/config"
  }

  part {
    content_type = "text/cloud-config"
    content = data.template_file.cloud_init.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content = data.template_file.install_script.rendered
  }
}

data template_file "cloud_init" {
  template = file("${path.module}/files/cloud-init.yaml")

  vars = {
    consul_config = jsonencode(data.template_file.consul_config.rendered)
    dnsmasq = jsonencode(file("${path.module}/files/dnsmasq-consul.conf"))
    consul_systemd = jsonencode(file("${path.module}/files/consul-server.service"))
  }
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