datacenter = "${datacenter}"
server = true
ui = true
leave_on_terminate = "${leave_on_terminate}"
skip_leave_on_interrupt  = true
disable_update_check = true
log_level = "warn"
data_dir = "/opt/consul/data"
client_addr = "0.0.0.0"
bootstrap_expect = "${bootstrap_expect}"
retry_join = [
  "provider=aws region=${aws_region} tag_key=${join_ec2_tag_key} tag_value=${join_ec2_tag}"
]
addresses = {
  http = "0.0.0.0"
}
connect = {
  enabled = true
}
autopilot = {
  cleanup_dead_servers = true
  last_contact_threshold = "200ms"
  max_trailing_logs = 250
  server_stabilization_time = "10s"
  redundancy_zone_tag = "az"
  disable_upgrade_migration = false
  upgrade_version_tag = ""
}