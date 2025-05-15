data "onepassword_vault" "main"{
  name = var.vault_name
}

data "onepassword_item" "secret" {
  count = var.secret_name != null ? 1 : 0
  vault = data.onepassword_vault.main.uuid
  title = var.secret_name
}


locals {
  // Only process if the secret exists (count > 0)
  secret_fields = var.secret_name != null ? merge(
    // Basic fields at the root level
    {
      "username" = try(data.onepassword_item.secret[0].username, null)
      "password" = try(data.onepassword_item.secret[0].password, null)
      "url"      = try(data.onepassword_item.secret[0].url, null)
    },
    // Process all sections and their fields
    flatten([
      for section in try(data.onepassword_item.secret[0].section, []) : {
        for field in try(section.field, []) :
        "${field.label}" => field.value
      }
    ])...
  ) : {}
}

output "secret_data" {
  value     = local.secret_fields
  sensitive = true
}

output "secret" {
  value = data.onepassword_item.secret[0]
  sensitive = true
}

output "vault_id" {
  value = data.onepassword_vault.main.uuid
}