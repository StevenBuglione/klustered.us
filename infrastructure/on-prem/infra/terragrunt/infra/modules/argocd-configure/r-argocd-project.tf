resource "kubernetes_manifest" "argocd_project_dev" {
  manifest = yamldecode(data.http.project_dev_yaml.response_body)
}