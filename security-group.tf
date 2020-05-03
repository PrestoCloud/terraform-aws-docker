resource "aws_security_group" "ssh_from_other_ec2_instances" {
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ssh_from_other_ec2_instances" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
  security_group_id = aws_security_group.ssh_from_other_ec2_instances.id
  source_security_group_id = aws_security_group.ssh_from_other_ec2_instances.id
}

resource "aws_security_group_rule" "swarm_ports" {
  type = "ingress"
  from_port = 2377
  to_port = 2377
  protocol = "tcp"
  # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
  security_group_id = aws_security_group.ssh_from_other_ec2_instances.id
  source_security_group_id = aws_security_group.ssh_from_other_ec2_instances.id
}

resource "aws_security_group_rule" "mesh_routing_0" {
  type = "ingress"
  from_port = 7946
  to_port = 7946
  protocol = "tcp"
  # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
  security_group_id = aws_security_group.ssh_from_other_ec2_instances.id
  source_security_group_id = aws_security_group.ssh_from_other_ec2_instances.id
}
resource "aws_security_group_rule" "mesh_routing_1" {
  type = "ingress"
  from_port = 4789
  to_port = 4789
  protocol = "udp"
  # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
  security_group_id = aws_security_group.ssh_from_other_ec2_instances.id
  source_security_group_id = aws_security_group.ssh_from_other_ec2_instances.id
}

resource "aws_security_group_rule" "mesh_routing_2" {
  type = "ingress"
  from_port = 7946
  to_port = 7946
  protocol = "udp"
  # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
  security_group_id = aws_security_group.ssh_from_other_ec2_instances.id
  source_security_group_id = aws_security_group.ssh_from_other_ec2_instances.id
}

# Retrieve current environment IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group_rule" "ssh_from_my_computer" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.ssh_from_other_ec2_instances.id
}

/* Default security group */
resource "aws_security_group" "allow_http_traffic" {
  name = "${local.stack_name}-http-in"
  description = "Allow all HTTP traffic in and out on port 80"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
    self = true
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
    self = true
  }

  tags = {
    Name = "${local.stack_name}-http"
  }
}

resource "aws_security_group" "trust_internal_traffic" {
  name = "${local.stack_name}-trust-internal-traffic"
  description = "Allow all traffic between servers in this group"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "trust_internal_traffic" {
  type = "ingress"
  protocol = "all"
  from_port = 0
  to_port = 0
  cidr_blocks = ["10.0.0.0/8"]
  security_group_id = aws_security_group.trust_internal_traffic.id
}

