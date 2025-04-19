remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket         = "klustered.us"
    key            = "01-nas-services/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "klustered.us-lock-table"
  }
}

terraform {
  source = "../../infra//modules/nas-docker-services"
}

inputs = {
  vault_name = "klustered.us"
  secret_name = "1password-credentials"
}
