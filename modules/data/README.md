# Module data

RDS PostgreSQL 16 Multi-AZ + 2 buckets S3 (primary + logs ALB).

## Usage

```hcl
module "data" {
  source = "../../modules/data"

  project_name = "kolab"
  environment  = "dev"

  vpc_id                 = module.networking.vpc_id
  private_db_subnet_ids  = module.networking.private_db_subnet_ids
  db_security_group_id   = module.security.db_security_group_id
  kms_key_arn            = module.security.kms_key_arn
  db_password_secret_arn = module.security.db_password_secret_arn
}