provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "hostmaster@${var.domain_name}"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  # subject_alternative_names = ["cloud.${var.domain_name}" ]

  dns_challenge {
    provider = "route53"
    config = {
      AWS_HOSTED_ZONE_ID    = aws_route53_zone.public.zone_id
      AWS_ACCESS_KEY_ID     = var.access_key
      AWS_SECRET_ACCESS_KEY = var.secret_key
      AWS_REGION            = var.region
    }
  }
}