# AMI Amazon Linux 2023  l'image OS pour nos EC2
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Récupère la région AWS (eu-west-3)
data "aws_region" "current" {}

# Clé privée RSA - le cadenas secret du certificat
resource "tls_private_key" "cert" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Certificat HTTPS auto-signé valable 1 an
resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.cert.private_key_pem

  subject {
    common_name  = "nextcloud-${var.environment}.kolab.local"
    organization = "Kolab"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
  ]
}

# Dépose le certificat dans AWS ACM pour que l'ALB puisse l'utiliser
resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.cert.private_key_pem
  certificate_body = tls_self_signed_cert.cert.cert_pem
}