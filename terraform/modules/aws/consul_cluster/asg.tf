module "consul_cluster" {
  source = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = "example-with-ec2"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "${var.cluster_name}-lc"

  image_id = local.ami_id[var.architecture]
  instance_type = var.instance_type
  security_groups = [
    module.ssh_sg.this_security_group_id,
    module.consul_sg.this_security_group_id
  ]
  associate_public_ip_address = true
  recreate_asg_when_lc_changes = true

  key_name = var.ssh_key_name
  iam_instance_profile = aws_iam_instance_profile.consul_autodiscovery.name
  user_data_base64 = base64encode(data.template_file.config_script.rendered)

  root_block_device = [
    {
      volume_size = "8"
      volume_type = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name = "${var.cluster_name}-asg"
  vpc_zone_identifier = var.subnets
  health_check_type = "EC2"
  min_size = var.servers
  max_size = var.servers
  desired_capacity = var.servers
  wait_for_capacity_timeout = 0
  service_linked_role_arn = aws_iam_service_linked_role.autoscaling.arn

  tags = [
    {
      key = "Name"
      value = var.cluster_name
      propagate_at_launch = true
    },
    {
      key = "Environment"
      value = "shared"
      propagate_at_launch = true
    },
    {
      key = "Terraform"
      value = "true"
      propagate_at_launch = true
    },
    {
      key = "Application"
      value = "consul"
      propagate_at_launch = true
    },
    {
      key = "ConsulDiscovery"
      value = var.cluster_name
      propagate_at_launch = true
    },
  ]
}

resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling"
  custom_suffix    = var.cluster_name

  # Sometimes good sleep is required to have some IAM resources created before they can be used
  provisioner "local-exec" {
    command = "sleep 10"
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
