include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../infra//modules/argocd-install"
}

inputs = {
  argocd_admin_password = "password"
  argo_project_dev_url = "https://raw.githubusercontent.com/StevenBuglione/k3s-argocd-boot/master/registry/projects/development/project-dev.yml"
  argo_root_app_dev_url = "https://raw.githubusercontent.com/StevenBuglione/k3s-argocd-boot/master/registry/projects/development/root-app-dev.yml"
}
