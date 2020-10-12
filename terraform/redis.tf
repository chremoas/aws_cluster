module "redis" {
  source = "umotif-public/elasticache-redis/aws"
  version = "~> 1.1.0"

  name_prefix           = "chremoas-redis"
  number_cache_clusters = 1
  node_type             = "cache.t3.micro"

  engine_version           = "5.0.6"
  port                     = 6379
  maintenance_window       = "mon:03:00-mon:04:00"
  snapshot_window          = "04:00-06:00"
  snapshot_retention_limit = 7

  automatic_failover_enabled = true

  at_rest_encryption_enabled = false
  transit_encryption_enabled = false
//  auth_token                 = "laio8ha2l3iuralkewjrfb"

  apply_immediately = true
  family            = "redis5.0"
  description       = "Redis for Chremoas."

  subnet_ids = module.primary.private_subnets
  vpc_id     = module.primary.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  parameter = [
    {
      name  = "repl-backlog-size"
      value = "16384"
    }
  ]

  tags = {
    Application = "chremoas"
    Environment = "aba"
    Terraform = "true"
  }
}