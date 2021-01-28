output "manager_ip" {
  value = aws_instance.swarm_manager.public_ip
}

output "wildcard_cert_key" {
  value = acme_certificate.certificate.private_key_pem
}

output "wildcard_cert_pem" {
  # value = acme_certificate.certificate.certificate_pem
  value = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
}

output "domain_name" {
  value = var.domain_name
}