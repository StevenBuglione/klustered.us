include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../infra//modules/argocd-configure"
}

dependency "argocd_install" {
  config_path = "../01-install-argocd"

  mock_outputs = {
    # Add appropriate mock values that match what your module expects
    # For example:
    argocd_namespace = "argocd"
    argocd_server_service = "argocd-server"
    # Add other expected outputs here
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "apply"]
}

# Use depends_on to ensure proper ordering
dependencies {
  paths = ["../01-install-argocd"]
}

inputs = {
  argocd_admin_password = "password"
  argo_project_dev_url = "https://raw.githubusercontent.com/StevenBuglione/k3s-argocd-boot/master/registry/projects/development/project-dev.yml"
  argo_root_app_dev_url = "https://raw.githubusercontent.com/StevenBuglione/k3s-argocd-boot/master/registry/projects/development/root-app-dev.yml"
}
