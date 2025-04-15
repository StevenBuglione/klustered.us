module "one-password-credentials" {
  source = "../one-password"
  vault_name = var.vault_name
  secret_name = var.one_password_credentials_secret_name
}

module "minio-root-user" {
  source = "../one-password"
  vault_name = var.vault_name
  secret_name = var.minio_root_user_secret_name
}

module "minio-root-password" {
  source = "../one-password"
  vault_name = var.vault_name
  secret_name = var.minio_root_password_secret_name
}
