resource "onepassword_item" "minio_access_key" {
  vault    = var.vault_name
  title    = "minio-access-key"
  category = "secure_note"

  section {
    label = "credential"

    field {
      label = "access-key"
      value = minio_iam_user.admin_user.id
      type = "STRING"
    }
  }
}

resource "onepassword_item" "minio_secret_key" {
  vault    = var.vault_name
  title    = "minio-secret-key"
  category = "secure_note"

  section {
    label = "credential"

    field {
      label = "secret-key"
      value = minio_iam_user.admin_user.secret
      type = "STRING"
    }
  }
}