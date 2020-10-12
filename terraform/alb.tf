//# Create a new load balancer
//
//locals {
//  enable_custom_domain = var.dns_zone == "" ? false : true
//  custom_endpoint      = "${coalesce(var.hostname, data.aws_vpc.vpc.tags["Name"])}.${var.dns_zone}"
//  consul_url_protocol  = local.enable_custom_domain ? "https" : "http"
//  consul_url_hostname  = local.enable_custom_domain ? local.custom_endpoint : aws_alb.consul.dns_name
//  consul_url           = "${local.consul_url_protocol}://${local.consul_url_hostname}"
//}
//
resource "aws_alb" "arm_cluster" {
  name = "shared"
  internal        = false
  subnets         = module.primary.public_subnets
  load_balancer_type = "network"

  tags = {
    Application = "arm_cluster"
    Environment = "shared"
    Terraform = "true"
  }

//  access_logs {
//    enabled = var.lb_logs_enabled
//    bucket = var.alb_log_bucket
//    prefix = "logs/elb/${data.aws_vpc.vpc.tags["Name"]}/consul"
//  }
}

resource "aws_autoscaling_attachment" "quassel" {
  autoscaling_group_name = module.ecs_arm_cluster.autoscaling_group_name
  alb_target_group_arn = aws_alb_target_group.quassel.arn
}

# DNS Alias for the LB
resource "aws_route53_record" "quassel" {
  zone_id = aws_route53_zone.fouramlunch_net.zone_id
  name    = "quassel.aws.4amlunch.net"
  type    = "A"

  alias {
    name                   = aws_alb.arm_cluster.dns_name
    zone_id                = aws_alb.arm_cluster.zone_id
    evaluate_target_health = false
  }
}

//# Create a new target group
resource "aws_alb_target_group" "quassel" {
  name = "quassel"
  port                 = 4242
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
resource "aws_alb_listener" "quassel" {
  load_balancer_arn = aws_alb.arm_cluster.arn
  port              = "4242"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_alb_target_group.quassel.arn
    type             = "forward"
  }
}

//resource "aws_alb_listener" "consul_http" {
//  count             = local.enable_custom_domain ? 0 : 1
//  load_balancer_arn = aws_alb.consul.arn
//  port              = "80"
//  protocol          = "HTTP"
//
//  default_action {
//    target_group_arn = aws_alb_target_group.consul_ui.arn
//    type             = "forward"
//  }
//}
//
//resource "aws_alb_listener_certificate" "consul_https" {
//  count           = local.enable_custom_domain ? 1 : 0
//  listener_arn    = aws_alb_listener.consul_https[0].arn
//  certificate_arn = data.aws_acm_certificate.cert[0].arn
//}