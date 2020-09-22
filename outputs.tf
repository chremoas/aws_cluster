output "bastion_key" {
  value = module.bastion_key_pair.this_key_pair_fingerprint
}

output "bastion_address" {
  value = module.bastion.public_ip
}

output "db_password" {
  value = module.chremoas_db.this_rds_cluster_master_password
}

output "db_address" {
  value = module.chremoas_db.this_rds_cluster_endpoint
}