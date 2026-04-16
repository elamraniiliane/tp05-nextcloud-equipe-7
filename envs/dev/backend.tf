terraform {
  required_version = ">= 1.7.0"

  backend "s3" {
    bucket         = "tf-state-equipe-7-iliane-kolab"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-west-3"
    encrypt        = true
    kms_key_id     = "alias/tf-state-equipe-7-iliane"
  }
}
