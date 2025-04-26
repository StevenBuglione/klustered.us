resource "docker_image" "op_connect_api" {
  name = "1password/connect-api:latest"
}

resource "docker_image" "op_connect_sync" {
  name = "1password/connect-sync:latest"
}

resource "docker_container" "op_connect_api" {
  name    = "op-connect-api"
  image   = docker_image.op_connect_api.image_id
  restart = "always"

  ports {
    internal = 8080
    external = 8080
  }

  volumes {
    container_path = "/home/opuser/.op/1password-credentials.json"
    host_path      = "/root/1password/1password-credentials.json"
    read_only      = true
  }

  volumes {
    container_path = "/home/opuser/.op/data"
    volume_name    = docker_volume.op_data.name
  }

  depends_on = [system_file.one-password-credentials-json, docker_image.op_connect_api]
}

resource "docker_container" "op_connect_sync" {
  name    = "op-connect-sync"
  image   = docker_image.op_connect_sync.image_id
  restart = "always"

  ports {
    internal = 8080
    external = 8081
  }

  volumes {
    container_path = "/home/opuser/.op/1password-credentials.json"
    host_path      = "/root/1password/1password-credentials.json"
    read_only      = true
  }

  volumes {
    container_path = "/home/opuser/.op/data"
    volume_name    = docker_volume.op_data.name
  }

  depends_on = [system_file.one-password-credentials-json, docker_image.op_connect_sync]
}

resource "docker_volume" "op_data" {
  name = "op_data"
}