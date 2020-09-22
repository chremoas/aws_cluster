module "chremoas_db" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name = "chremoas-db"

  engine = "aurora-postgresql"
  engine_mode = "serverless"
  engine_version = "10.7"
  username = "postgres"

  replica_scale_enabled = false
  replica_count = 0

  vpc_id = module.primary.vpc_id
  subnets = module.primary.private_subnets

  allowed_cidr_blocks = module.primary.public_subnets_cidr_blocks
  instance_type = "db.t3.medium"
  storage_encrypted = true
  apply_immediately = true


  db_parameter_group_name = "default"
  db_cluster_parameter_group_name = "default.aurora-postgresql10"

  scaling_configuration = {
    auto_pause = false
    max_capacity = 2
    min_capacity = 2
    seconds_until_auto_pause = 300
    timeout_action = "RollbackCapacityChange"
  }

  preferred_backup_window = "05:01-05:31"
  preferred_maintenance_window = "wed:07:22-wed:07:52"

  copy_tags_to_snapshot = true

  tags = {
    Application = "chremoas"
    Environment = "aba"
    Terraform = "true"
  }
}
