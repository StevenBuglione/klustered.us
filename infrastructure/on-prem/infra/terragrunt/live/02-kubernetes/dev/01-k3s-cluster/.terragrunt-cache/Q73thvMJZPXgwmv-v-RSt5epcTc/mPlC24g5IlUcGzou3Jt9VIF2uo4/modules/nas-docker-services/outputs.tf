output "minio-root-password" {
  value = module.minio-root-password.secret.credential
  description = "Minio root password"
  sensitive = true
}

output "minio-root-user" {
  value = module.minio-root-user.secret.credential
  description = "Minio root user"
  sensitive = true
}

output "minio-endpoint" {
  value = module.minio-endpoint.secret.credential
  description = "Minio root user"
  sensitive = true
}

output "one-password-connect-token" {
  value = module.one-password-connect-token.secret.credential
  description = "1Password Connect token"
  sensitive = true
}

output "one-password-connect-url" {
  value = var.one_password_connect_url
  description = "1Password Connect URL"
}

data "onepassword_vault" "main"{
  name = var.vault_name
}

output "onepassword-vault-id" {
  value = data.onepassword_vault.main.uuid
  description = "1Password vault ID"
  sensitive = true
}