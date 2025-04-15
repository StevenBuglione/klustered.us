variable "vault_name" {
  type        = string
  description = "ID of the 1Password vault containing the item"
  nullable = false
}

variable "one_password_credentials_secret_name" {
  type = string
  description = "Name of the secret to request from one password connect server"
  default = "1password-credentials"
}

variable "minio_root_user_secret_name" {
  type = string
  description = "Name of the secret to request the minio root user"
  default = "minio-root-user"
}

variable "minio_root_password_secret_name" {
  type = string
  description = "Name of the secret to request the minio root password"
  default = "minio-root-password"
}