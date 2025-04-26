// Input variables for the LXD cluster module

variable "nodes" {
  description = "List of cluster nodes with their name, address, and role."
  type        = list(object({
    name    = string   // Hostname to assign in the cluster
    address = string   // IP or DNS for SSH access and cluster communication
    role    = string   // "master" for bootstrap node, "worker" for additional nodes
  }))
}

variable "ssh_user" {
  description = "SSH username for all cluster nodes."
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key for authenticating to the nodes."
  type        = string
}

variable "cluster_password" {
  description = "Trust password for the LXD cluster (used for joining nodes)."
  type        = string
}
