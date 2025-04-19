// live/dev/secrets/terragrunt.hcl

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../infra//modules/one-password"
}


inputs = {
  vault_name = "klustered.us"
  secret_name = "minio"
}

