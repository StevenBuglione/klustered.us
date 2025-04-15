terraform {
  source = "../../../infra//modules/nas-docker-services"
}

inputs = {
  vault_name = "klustered.us"
  secret_name = "1password-credentials"
}