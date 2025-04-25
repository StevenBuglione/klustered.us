// Local values to identify master node
locals {
  master_node = element([for n in var.nodes : n if n.role == "master"], 0)
}

// Initialize LXD cluster on the master node
resource "null_resource" "master" {
  // Store values needed for destroy phase
  triggers = {
    master_name = local.master_node.name
    master_address = local.master_node.address
    ssh_user = var.ssh_user
    ssh_key_path = var.ssh_private_key_path
  }

  provisioner "remote-exec" {
    when = create

    connection {
      host        = local.master_node.address
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      timeout     = "60s"
    }

    inline = [
      "echo 'Checking if LXD is installed...'",
      "if ! command -v lxd > /dev/null; then",
      "  echo 'Installing LXD...'",
      "  sudo apt-get update",
      "  sudo apt-get install -y snapd",
      "  sudo snap install lxd",
      "  sudo usermod -a -G lxd $USER",
      "  echo 'LXD installed successfully'",
      "fi",
      "echo 'Initializing LXD if not already configured...'",
      "if ! lxc info 2>/dev/null | grep -q 'server_clustered: true'; then",
      "  echo 'Initializing LXD cluster on master ${local.master_node.name}...'",
      "  cat > /tmp/lxd_preseed.yml <<'EOL'",
      "config:",
      "  core.trust_password: ${var.cluster_password}",
      "  core.https_address: ${local.master_node.address}:8443",
      "  images.auto_update_interval: 15",
      "storage_pools:",
      "- name: default",
      "  driver: dir",
      "  config:",
      "    source: \"\"",
      "profiles:",
      "- name: default",
      "  devices:",
      "    root:",
      "      path: /",
      "      pool: default",
      "      type: disk",
      "    eth0:",
      "      name: eth0",
      "      nictype: macvlan",
      "      parent: eth0",
      "      type: nic",
      "cluster:",
      "  enabled: true",
      "  server_name: ${local.master_node.name}",
      "EOL",
      "  sudo lxd init --preseed < /tmp/lxd_preseed.yml",
      "  sleep 10", # Allow more time for cluster to initialize
      "else",
      "  echo 'Master already in a cluster, skipping initialization'",
      "fi",
      "# Verify cluster status",
      "sudo lxc cluster list || echo 'Failed to list cluster'"
    ]
  }

  # Clean up on destroy - ONLY use self.triggers
  provisioner "remote-exec" {
    when = destroy
    on_failure = continue

    connection {
      host        = self.triggers.master_address
      user        = self.triggers.ssh_user
      private_key = file(self.triggers.ssh_key_path)
      timeout     = "60s"
    }

    inline = [
      "echo 'Cleaning up LXD on master node...'",
      "if command -v lxd > /dev/null; then",
      "  echo 'Stopping all containers and instances...'",
      "  sudo lxc list --format csv -c n | xargs -I{} sudo lxc stop {} --force || true",
      "  echo 'Removing all containers and instances...'",
      "  sudo lxc list --format csv -c n | xargs -I{} sudo lxc delete {} --force || true",
      "  echo 'Uninstalling LXD...'",
      "  sudo snap remove --purge lxd || true",
      "fi",
      "echo 'Cleanup completed on master node'"
    ]
  }
}

// Join worker nodes to the cluster
resource "null_resource" "workers" {
  for_each = { for node in var.nodes : node.name => node if node.role == "worker" }
  depends_on = [null_resource.master]

  // Store values needed during destroy phase
  triggers = {
    node_name = each.value.name
    node_address = each.value.address
    master_address = local.master_node.address
    master_name = local.master_node.name
    ssh_user = var.ssh_user
    ssh_key_path = var.ssh_private_key_path
  }

  // Create-time provisioner with its own connection
  provisioner "remote-exec" {
    when = create

    connection {
      host        = each.value.address
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      timeout     = "60s"
    }

    inline = [
      "echo 'Checking if LXD is installed on ${each.value.name}...'",
      "if ! command -v lxd > /dev/null; then",
      "  echo 'Installing LXD on ${each.value.name}...'",
      "  sudo apt-get update",
      "  sudo apt-get install -y snapd",
      "  sudo snap install lxd",
      "  sudo usermod -a -G lxd $USER",
      "  echo 'LXD installed successfully on ${each.value.name}'",
      "fi",
      "# Check if already in cluster",
      "if lxc info 2>/dev/null | grep -q 'server_clustered: true'; then",
      "  echo 'Node ${each.value.name} already in a cluster, checking if correct cluster'",
      "  # If already in cluster but not the right one, we'll need to leave first",
      "  if ! lxc cluster list 2>/dev/null | grep -q '${local.master_node.name}'; then",
      "    echo 'Node in wrong cluster, leaving current cluster first'",
      "    sudo snap remove --purge lxd",
      "    sudo snap install lxd",
      "    echo 'LXD reinstalled, will now join correct cluster'",
      "  else",
      "    echo 'Node already in the correct cluster, skipping join'",
      "    exit 0",
      "  fi",
      "fi",
      "# If we reach here, we need to join the cluster",
      "echo 'Joining node ${each.value.name} to LXD cluster...'",
      "echo '${replace(file(var.ssh_private_key_path), "\n", "\\n")}' > /tmp/tf_key.pem && chmod 600 /tmp/tf_key.pem",
      "TOKEN=$(ssh -o StrictHostKeyChecking=no -i /tmp/tf_key.pem ${var.ssh_user}@${local.master_node.address} \"sudo lxc cluster add ${each.value.name} --quiet\" | tr -d '\\n')",
      "cat > /tmp/lxd_join.yml <<EOL",
      "cluster:",
      "  enabled: true",
      "  server_name: ${each.value.name}",
      "  server_address: ${each.value.address}:8443",
      "  cluster_address: ${local.master_node.address}:8443",
      "  cluster_token: $TOKEN",
      "  member_config:",
      "  - entity: storage-pool",
      "    name: default",
      "    key: source",
      "    value: \"\"",
      "EOL",
      "sudo lxd init --preseed < /tmp/lxd_join.yml || echo 'Failed to join cluster, may need manual intervention'",
      "rm -f /tmp/tf_key.pem /tmp/lxd_join.yml"
    ]
  }

  // First remove from cluster if still part of it
  provisioner "remote-exec" {
    when = destroy
    on_failure = continue

    connection {
      host        = self.triggers.master_address
      user        = self.triggers.ssh_user
      private_key = file(self.triggers.ssh_key_path)
      timeout     = "30s"
    }

    inline = [
      "echo \"Attempting to remove node ${self.triggers.node_name} from cluster...\"",
      "if command -v lxc > /dev/null; then",
      "  # Check if node is in the cluster",
      "  if timeout 10s sudo lxc cluster list 2>/dev/null | grep -q \"${self.triggers.node_name}\"; then",
      "    echo \"Node ${self.triggers.node_name} found in cluster, removing...\"",
      "    # Give reasonable timeout to avoid hanging",
      "    timeout 20s sudo lxc cluster remove ${self.triggers.node_name} --yes || echo \"Removal timed out or failed\"",
      "  else",
      "    echo \"Node ${self.triggers.node_name} not found in cluster\"",
      "  fi",
      "else",
      "  echo \"LXC not installed on master node, cannot remove cluster node\"",
      "fi",
      "exit 0"  # Always exit cleanly to prevent hanging
    ]
  }

  # Also clean up the worker node itself
  provisioner "remote-exec" {
    when = destroy
    on_failure = continue

    connection {
      host        = self.triggers.node_address
      user        = self.triggers.ssh_user
      private_key = file(self.triggers.ssh_key_path)
      timeout     = "30s"
    }

    inline = [
      "echo \"Cleaning up LXD on worker node ${self.triggers.node_name}...\"",
      "if command -v lxd > /dev/null; then",
      "  echo 'Stopping all containers and instances...'",
      "  sudo lxc list --format csv -c n | xargs -I{} sudo lxc stop {} --force || true",
      "  echo 'Removing all containers and instances...'",
      "  sudo lxc list --format csv -c n | xargs -I{} sudo lxc delete {} --force || true",
      "  echo 'Uninstalling LXD...'",
      "  sudo snap remove --purge lxd || true",
      "fi",
      "rm -f /tmp/tf_key.pem /tmp/lxd_join.yml",
      "echo 'Cleanup completed on worker node'",
      "exit 0"  # Always exit cleanly
    ]
  }
}