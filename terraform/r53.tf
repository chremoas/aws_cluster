resource "aws_route53_zone" "fouramlunch_net" {
  name = "4amlunch.net"
}

resource "aws_route53_record" "test1" {
  name = "test1.aws.4amlunch.net"
  type = "A"
  zone_id = aws_route53_zone.fouramlunch_net.zone_id
  records = ["1.2.3.4"]
  ttl = 3600000
}

output "dns_servers" {
  value = aws_route53_zone.fouramlunch_net.name_servers
}