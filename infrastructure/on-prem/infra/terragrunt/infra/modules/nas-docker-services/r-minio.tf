resource "docker_image" "minio" {
  name = "minio/minio:latest"
}

resource "docker_container" "minio" {
  name    = "minio"
  image   = docker_image.minio.image_id
  restart = "always"

  ports {
    internal = 9000
    external = 9769
  }

  ports {
    internal = 9001
    external = 9768
  }

  env = [
    "MINIO_ROOT_USER=${module.minio-root-user.secret.credential}",
    "MINIO_ROOT_PASSWORD=${module.minio-root-password.secret.credential}"
  ]

  volumes {
    host_path      = "/mnt/disk3/appdata/minio"
    container_path = "/data"
  }

  command = [
    "server",
    "/data",
    "--console-address",
    ":9001"
  ]

  depends_on = [system_folder.minio]
}
