variable "server_nodes" {
  type = list(object({
    name = string
    ip = string
  }))
  description = "List of server nodes with name and IP"
}

variable "agent_nodes" {
  type = list(object({
    name = string
    ip = string
  }))
  description = "List of agent nodes with name and IP"
  default = []
}

variable "k3s_connection" {
  type = object({
    user        = string
    private_key = string
    timeout     = string
  })
}

variable "k3s_install_env_vars" {
  type    = map(string)
  default = {}
}

variable "k3s_global_flags" {
  type    = list(string)
  default = ["--disable=traefik","--write-kubeconfig-mode=644"]
}

variable "argocd_admin_password" {
  description = "Argo CD admin user password (plaintext input, will be stored as bcrypt hash in cluster)"
  type        = string
  sensitive   = true
}

variable "argo_project_dev_url"{
  description = "The raw git url to the argocd project file"
  type = string
}

variable "argo_root_app_dev_url"{
  description = "The raw git url to the argocd root app file"
  type = string
}

variable "k3s_version" {
  type    = string
  default = "latest"
}