module "shared_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"
  identifier = "shared"

  engine            = "postgres"
  engine_version    = "12.4"
  instance_class    = "db.t2.micro"
  allocated_storage = 5
  storage_encrypted = false

  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  name = "shared"

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = "shared"
  password = "liauwhflkajhbdcvliausgh"
  port     = "5432"

  vpc_security_group_ids = [module.pgsql_sg.this_security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = {
    Application = "postgresql"
    Terraform = "true"
    Environment = "shared"
  }

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = module.primary.private_subnets

  # DB parameter group
  family = "postgres12"

  # DB option group
  major_engine_version = "12"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "shared"

  # Database Deletion Protection
  deletion_protection = false
}

module "pgsql_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/postgresql"

  name        = "shared-db-ports"
  description = "Security group for RDS postgresql"
  vpc_id      = module.primary.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/16"]
}
