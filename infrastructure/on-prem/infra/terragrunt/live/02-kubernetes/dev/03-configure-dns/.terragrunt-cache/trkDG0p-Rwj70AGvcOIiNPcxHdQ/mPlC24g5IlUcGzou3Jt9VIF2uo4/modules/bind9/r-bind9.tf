# Local variables for configuration
locals {
  bind9_image    = "ubuntu/bind9:latest"
  container_name = "bind9-dns"
  domain         = "klustered.us"
  target_ip      = "10.10.10.50"

  # Bind9 configurations
  named_conf_options = <<-EOT
  options {
    directory "/var/cache/bind";
    forwarders {
      1.1.1.1;
      8.8.8.8;
    };
    allow-query { any; };
    listen-on { any; };
    recursion yes;
  };
EOT

  named_conf_local = <<-EOT
    zone "${local.domain}" {
      type master;
      file "/etc/bind/zones/${local.domain}.zone";
    };
  EOT

  zone_file = <<-EOT
    $TTL 86400
    @       IN      SOA     ns.${local.domain}. home.${local.domain}. (
                            2023010101  ; Serial
                            3600               ; Refresh
                            1800               ; Retry
                            604800             ; Expire
                            86400              ; Minimum TTL
    )

    @       IN      NS      ns.${local.domain}.
    @       IN      A       ${local.target_ip}
    ns1     IN      A       ${local.target_ip}

    ; Wildcard entry to catch all subdomains
    *       IN      A       ${local.target_ip}
  EOT
}

# Create directories on the host
resource "system_folder" "bind9_config_dir" {
  path = "/opt/bind9/config"
}

resource "system_folder" "bind9_zones_dir" {
  path = "/opt/bind9/config/zones"
  depends_on = [system_folder.bind9_config_dir]
}

resource "system_folder" "bind9_cache_dir" {
  path = "/opt/bind9/cache"
}

# Create named.conf.options file
resource "system_file" "named_conf_options" {
  path    = "/opt/bind9/config/named.conf.options"
  content = local.named_conf_options
  depends_on = [system_folder.bind9_config_dir]
}

# Create named.conf.local file
resource "system_file" "named_conf_local" {
  path    = "/opt/bind9/config/named.conf.local"
  content = local.named_conf_local
  depends_on = [system_folder.bind9_config_dir]
}

# Create main named.conf file
resource "system_file" "named_conf" {
  path    = "/opt/bind9/config/named.conf"
  content = "include \"/etc/bind/named.conf.options\";\ninclude \"/etc/bind/named.conf.local\";"
  depends_on = [system_folder.bind9_config_dir]
}

# Create zone file
resource "system_file" "zone_file" {
  path    = "/opt/bind9/config/zones/${local.domain}.zone"
  content = local.zone_file
  depends_on = [system_folder.bind9_zones_dir]
}

# Update the null_resource to match your provider configuration
resource "null_resource" "set_permissions" {
  depends_on = [
    system_file.named_conf,
    system_file.named_conf_options,
    system_file.named_conf_local,
    system_file.zone_file,
    system_folder.bind9_cache_dir
  ]

  connection {
    type        = "ssh"
    user        = "root"
    host        = "10.10.10.8"  # Match provider host
    private_key = file("~/.ssh/ansible-key")  # Match provider key
  }

  provisioner "remote-exec" {
    inline = [
      "chmod -R 755 /opt/bind9",
      "chown -R 100:101 /opt/bind9/cache"
    ]
  }
}

# Pull the Bind9 Docker image
resource "docker_image" "bind9" {
  name = local.bind9_image
}

# Run the Bind9 container
resource "docker_container" "bind9" {
  name  = local.container_name
  image = docker_image.bind9.image_id  # Changed from .latest to .image_id

  # Rest of the configuration remains the same
  restart = "always"

  ports {
    internal = 53
    external = 53
    protocol = "udp"
  }

  ports {
    internal = 53
    external = 53
    protocol = "tcp"
  }

  volumes {
    host_path      = "/opt/bind9/config"
    container_path = "/etc/bind"
  }

  volumes {
    host_path      = "/opt/bind9/cache"
    container_path = "/var/cache/bind"
  }

  depends_on = [
    null_resource.set_permissions
  ]
}