resource "aws_route53_zone" "private" {
  name = "presto"

  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "manager_dns" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "manager0"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.swarm_manager.private_ip]
}

resource "aws_route53_record" "worker_dns" {
  count   = length(aws_instance.swarm_worker)
  zone_id = aws_route53_zone.private.zone_id
  name    = "worker${count.index}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.swarm_worker[count.index].private_ip]
}

resource "aws_route53_record" "efs" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "efs"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_efs_mount_target.efs[0].dns_name]
}