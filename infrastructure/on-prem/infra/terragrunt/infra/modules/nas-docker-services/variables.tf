variable "vault_name" {
  type        = string
  description = "ID of the 1Password vault containing the item"
  default = "klustered.us"
}

variable "one_password_credentials_secret_name" {
  type = string
  description = "Name of the secret to request from one password connect server"
  default = "1password-credentials"
}

variable "one_password_connect_token_secret_name" {
  type = string
  description = "Name of the secret to request from one password connect server token"
  default = "OP_CONNECT_TOKEN"
}

variable "one_password_connect_url"{
  type = string
  description = "URL of the 1Password Connect server"
  default = "http://10.10.10.7:8080"
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

variable "minio_endpoint_name" {
  type = string
  description = "Name of the secret to request the minio endpoint"
  default = "minio-endpoint"
}