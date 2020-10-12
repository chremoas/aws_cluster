//
// ECS Traefik servers
//
resource "aws_cloudwatch_log_group" "traefik-shared" {
  name = "/ecs/traefik-shared"
}

data "template_file" "traefik-config" {
  template = file("${path.module}/files/traefik.json")

  vars = {
    ecs_cluster = module.ecs_arm_cluster.cluster_name
    aws_region = var.aws_region
    domain = "aws.4amlunch.net"
    awslogs_group = "/ecs/traefik-shared"
    awslogs_stream_prefix = "traefik-shared"
    awslogs_region = var.aws_region
  }
}

resource "aws_ecs_task_definition" "traefik" {
  family = "traefik"
  container_definitions = data.template_file.traefik-config.rendered

  network_mode = "host"

  task_role_arn = aws_iam_role.traefik_discovery.arn
}

resource "aws_ecs_service" "traefik" {
  name = "traefik"
  cluster = module.ecs_arm_cluster.cluster_id
  task_definition = aws_ecs_task_definition.traefik.arn
  scheduling_strategy = "DAEMON"
}

# DNS Alias for the LB
resource "aws_route53_record" "traefik" {
  zone_id = aws_route53_zone.fouramlunch_net.zone_id
  name    = "traefik.aws.4amlunch.net"
  type    = "A"

  alias {
    name                   = aws_alb.arm_cluster.dns_name
    zone_id                = aws_alb.arm_cluster.zone_id
    evaluate_target_health = false
  }
}

resource "aws_autoscaling_attachment" "traefik" {
  autoscaling_group_name = module.ecs_arm_cluster.autoscaling_group_name
  alb_target_group_arn = aws_alb_target_group.traefik-80.arn
}

//# Create a new target group
resource "aws_alb_target_group" "traefik-80" {
  name = "traefik"
  port                 = 80
  protocol             = "TCP"
  vpc_id               = module.primary.vpc_id
  //  deregistration_delay = var.lb_deregistration_delay

  //  health_check {
  //    path    = "/ping"
  //    matcher = "200"
  //  }
  //
  //  stickiness {
  //    type    = "lb_cookie"
  //    enabled = true
  //  }

  tags = {
    Application = "arm_cluster"
    Environment = "shared"
    Terraform = "true"
  }
}

//
# Create a new alb listener
resource "aws_alb_listener" "traefik-80" {
  load_balancer_arn = aws_alb.arm_cluster.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_alb_target_group.traefik-80.arn
    type             = "forward"
  }
}

//
// IAM role for traefik
//
resource "aws_iam_role_policy" "traefik_discovery" {
  policy = data.aws_iam_policy_document.traefik_discovery.json
  role = aws_iam_role.traefik_discovery.id
}

data "aws_iam_policy_document" "traefik_discovery_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "traefik_discovery" {
  name = "traefik-autodiscovery"
  assume_role_policy = data.aws_iam_policy_document.traefik_discovery_assume_role.json

  tags = {
    Name = "traefik-discovery"
    Application = "traefik"
    Terraform = "true"
    Environment = "shared"
  }
}

data "aws_iam_policy_document" "traefik_discovery" {
  statement {
    effect = "Allow"
    actions = ["ecs:ListClusters"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["ecs:DescribeClusters"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["ecs:ListTasks"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["ecs:DescribeTasks"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["ecs:DescribeContainerInstances"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["ecs:DescribeTaskDefinition"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["ec2:DescribeInstances"]
    resources = ["*"]
  }
}
