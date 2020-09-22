resource "aws_ecs_task_definition" "consul" {
  family                = "service"
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