resource "aws_efs_file_system" "efs" {
  creation_token = "${local.stack_name}-efs"

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }


  tags = {
    Name = "${local.stack_name}"
  }
}

resource "aws_efs_mount_target" "efs" {
  count           = length(aws_subnet.public_subnets)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.public_subnets.*.id[count.index]
  security_groups = [aws_security_group.ssh_from_other_ec2_instances.id, aws_security_group.trust_internal_traffic.id]
}

output "efs_mount_ips" {
  value       = aws_efs_mount_target.efs.*.ip_address
  description = "IP Address for the EFS mounts"
}

output "efs_mountpoints" {
  value       = aws_efs_mount_target.efs.*.dns_name
  description = "DNS for the EFS mounts"
}