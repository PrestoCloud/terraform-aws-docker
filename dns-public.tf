resource "aws_route53_zone" "public" {
  name = var.domain_name
}

resource "aws_route53_record" "wildcard_dns" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "*"
  type    = "A"
  ttl     = "300"
  records = flatten([
    aws_instance.swarm_manager.public_ip,
    aws_instance.swarm_worker[*].public_ip
  ])
}

resource "aws_route53_record" "apex_dns" {
  zone_id = aws_route53_zone.public.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = "300"
  records = flatten([
    aws_instance.swarm_manager.public_ip,
    aws_instance.swarm_worker[*].public_ip
  ])
}