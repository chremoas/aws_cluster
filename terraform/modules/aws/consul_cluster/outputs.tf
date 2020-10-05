output "cluster_ips" {
  value = {
    "private_ips": aws_instance.consul_server.*.private_ip,
    "public_ips": aws_instance.consul_server.*.public_ip
  }
}