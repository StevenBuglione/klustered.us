resource "system_file" "one-password-credentials-json" {
  path    = "/root/1password/1password-credentials.json"
  content = module.one-password-credentials.secret.credential
  depends_on = [system_folder.one_password]
}