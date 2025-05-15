module "op-credentials" {
  source = "../one-password"
  vault_name = "klustered.us"
  secret_name = "1password-credentials"
}

module "onepassword-token" {
  source = "../one-password"
  vault_name = "klustered.us"
  secret_name = "OP_CONNECT_TOKEN"
}

resource "kubernetes_secret" "op_credentials" {
  metadata {
    name      = "op-credentials"
    namespace = "default"
  }

  data = {
    "1password-credentials.json" = module.op-credentials.secret.credential
  }
}

resource "kubernetes_secret" "onepassword_token" {
  metadata {
    name      = "onepassword-token"
    namespace = "default"
  }

  data = {
    "token" = module.onepassword-token.secret.credential
  }
}