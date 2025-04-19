include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../infra//modules/minio"
}

dependency "secrets" {
  config_path = "../01-docker-services"

  mock_outputs = {
    minio-root-password = "mock-root-password"
    minio-root-user = "mock-root-user"
    minio-endpoint = "mock-endpoint"
    onepassword-vault-id = "mock-vault-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

generate "provider" {
  path      = "provider_minio.tf"
  if_exists = "overwrite"
  contents  = <<EOF
  provider "minio" {
    minio_server = "${dependency.secrets.outputs.minio-endpoint}"
    minio_user   = "${dependency.secrets.outputs.minio-root-user}"
    minio_password = "${dependency.secrets.outputs.minio-root-password}"
  }
EOF
}

inputs = {
  minio_server = dependency.secrets.outputs.minio-endpoint
  state_bucket_name = "klustered.us"
  vault_name = dependency.secrets.outputs.onepassword-vault-id
}
