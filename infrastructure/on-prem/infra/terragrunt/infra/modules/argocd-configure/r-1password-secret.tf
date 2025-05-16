module "op-credentials" {
  source = "../one-password"
  vault_name = "klustered.us"
  secret_name = "op-credentials"
}

module "onepassword-token" {
  source = "../one-password"
  vault_name = "klustered.us"
  secret_name = "onepassword-token"
}

resource "kubernetes_secret" "op_credentials" {
  metadata {
    name      = "op-credentials"
    namespace = "default"
  }

  data = {
    "1password-credentials.json" = base64decode(module.op-credentials.secret.credential)
  }
}

resource "kubernetes_secret" "onepassword_token" {
  metadata {
    name      = "onepassword-token"
    namespace = "default"
  }

  data = {
    "token" = base64decode(module.onepassword-token.secret.credential)
  }
}