output "redis" {
  value = module.redis.elasticache_replication_group_primary_endpoint_address
}

output "db_endpoint" {
  value = module.shared_db.this_db_instance_endpoint
}