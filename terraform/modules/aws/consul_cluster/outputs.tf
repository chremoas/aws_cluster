output "consul_security_group" {
  value = module.consul_sg.this_security_group_id
}

output "ssh_security_group" {
  value = module.ssh_sg.this_security_group_id
}
