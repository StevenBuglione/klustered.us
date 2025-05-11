module "k3s_argocd_install" {
  source = "../argocd-install"
  argocd_admin_password = var.argocd_admin_password
  argo_project_dev_url = var.argo_project_dev_url
  argo_root_app_dev_url = var.argo_root_app_dev_url
}