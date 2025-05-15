terraform {
  required_providers {
    system = {
      source  = "neuspaces/system"
      version = ">= 0.5.0"
    }
    onepassword = {
      source  = "1password/onepassword"
      version = ">= 2.1.2"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = ">= 3.0.2"
    }
  }
}

provider "system" {
  ssh {
    user = "root"
    host = "10.10.10.8"
    private_key = file("~/.ssh/ansible-key")
  }
}

provider "docker" {
  host     = "ssh://root@10.10.10.8:22"
  ssh_opts = [
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
    "-i", "~/.ssh/ansible-key"
  ]
}