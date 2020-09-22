resource "aws_ecs_task_definition" "consul" {
  family                = "chremoas-consul"
  container_definitions = file("task-definitions/consul.json")

  volume {
    name      = "consul-storage"
    host_path = "/ecs/consul-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1c]"
  }
}

resource "aws_ecs_service" "consul" {
  name            = "chremoas-consul"
  cluster         = module.ecs_arm_cluster.cluster_id
  task_definition = aws_ecs_task_definition.consul.arn
  desired_count   = 2
//  iam_role        = aws_iam_role.foo.arn
//  depends_on      = [aws_iam_role_policy.foo]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

//  load_balancer {
//    target_group_arn = aws_lb_target_group.foo.arn
//    container_name   = "mongo"
//    container_port   = 8080
//  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}