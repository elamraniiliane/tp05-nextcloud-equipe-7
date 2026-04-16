# Module `compute`

Frontal applicatif : ALB + ASG + launch template + user_data Nextcloud.

Créé par le **Rôle 3 — Compute Engineer** lors du TP05.

## Contenu attendu

- Certificat TLS self-signed (provider `tls`) importé dans ACM
- ALB public + target group (health check `/status.php`) + 2 listeners (443 forward, 80 redirect 301)
- Launch template (Amazon Linux 2023, t3.small, IMDSv2, EBS chiffré)
- ASG min=1 / max=2 / desired=1
- user_data templatifié lançant `nextcloud:30-apache` en Docker

## Interface

Voir `variables.tf` et `outputs.tf`.

Consultez [role-3-compute.md](../../../cours/jour5/tp05-team-nextcloud/role-3-compute.md) pour le détail.

# Module compute

ALB + Auto Scaling Group + Launch Template pour Nextcloud en Docker.

## Usage

```hcl
module "compute" {
  source = "../../modules/compute"

  project_name = "kolab"
  environment  = "dev"

  # Inputs du module networking (Rôle 2)
  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnet_ids
  private_app_subnet_ids = module.networking.private_app_subnet_ids

  # Inputs du module security (Rôle 5)
  alb_security_group_id     = module.security.alb_security_group_id
  app_security_group_id     = module.security.app_security_group_id
  app_instance_profile_name = module.security.app_instance_profile_name
  db_password_secret_arn    = module.security.db_password_secret_arn
  admin_password_secret_arn = module.security.admin_password_secret_arn

  # Inputs du module data (Rôle 4)
  db_endpoint            = module.data.db_endpoint
  db_name                = module.data.db_name
  db_username            = module.data.db_username
  s3_primary_bucket_name = module.data.s3_primary_bucket_name
  s3_logs_bucket_name    = module.data.s3_logs_bucket_name
}
```

## Outputs

| Nom | Description |
|-----|-------------|
| `alb_dns_name` | DNS public de l'ALB |
| `alb_zone_id` | Zone Route53 de l'ALB |
| `asg_name` | Nom de l'ASG |
| `nextcloud_url` | URL HTTPS Nextcloud |
| `launch_template_id` | ID du Launch Template |
| `target_group_arn` | ARN du Target Group |