include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../infra//modules/nas-docker-services"
}

inputs = {
  vault_name = "klustered.us"
  secret_name = "1password-credentials"
}
