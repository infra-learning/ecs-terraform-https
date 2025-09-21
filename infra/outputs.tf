output "ns" {
  value = aws_route53_zone.root.name_servers
}

output "hosted_zone_id" {
  value = aws_route53_zone.root.zone_id
}
