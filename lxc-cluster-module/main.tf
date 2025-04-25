provider "null" {
  # (Optional: use the null provider if needed for null_resource, usually auto-included)
}

module "lxd_cluster" {
  source = "./modules/lxc"  // path to the module implementation

  nodes = [
    { name = "node1", address = "10.10.10.5", role = "master" },
    { name = "node2", address = "10.10.10.3", role = "worker" },
    { name = "node3", address = "10.10.10.4", role = "worker" },
    # { name = "node4", address = "10.10.10.6", role = "worker" }
  ]

  ssh_user             = "sbuglione"                        # SSH username on the nodes
  ssh_private_key_path = "~/.ssh/ansible-key"                 # Path to your private SSH key
  cluster_password     = "P@ssw0rd123!"                  # Cluster trust password for LXD
}
