// live/dev/secrets/terragrunt.hcl
terraform {
  source = "../../../infrastructure//modules/one-password"
}

inputs = {
  vault_name = "klustered.us"
  secret_name = "minio"
}
