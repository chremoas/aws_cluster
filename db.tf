module "db" {
  source                          = "terraform-aws-modules/rds-aurora/aws"

  name                            = "chremoas-db"

  engine                          = "aurora-postgresql"
  engine_mode                     = "serverless"
  engine_version                  = "11.8"

  replica_scale_enabled           = false
  replica_count                   = 0

  vpc_id                          = module.primary.vpc_id
  subnets                         = module.primary.private_subnets

  allowed_security_groups         = ["sg-12345678"]
  instance_type                   = "db.t3.medium"
  storage_encrypted               = true
  apply_immediately               = true
  monitoring_interval             = 10

  db_parameter_group_name         = "default"
  db_cluster_parameter_group_name = "default"

  tags                            = {
    Application = "chremoas"
    Environment = "aba"
    Terraform   = "true"
  }
}
