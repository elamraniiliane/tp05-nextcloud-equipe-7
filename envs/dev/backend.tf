# -----------------------------------------------------------------------------
# envs/dev/backend.tf
# Backend S3 natif (TF >= 1.10) avec locking via use_lockfile + KMS CMK.
# Le bucket + la CMK sont crees par bootstrap/create-state-bucket.sh.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket         = "tf-state-equipe-7-iliane-kolab"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    kms_key_id     = "alias/tf-state-equipe-7-iliane"
    use_lockfile   = true
  }
