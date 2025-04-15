resource "system_folder" "one_password" {
  path = "/root/1password"
  mode = 700
}

resource "system_folder" "appdata" {
  path = "/mnt/disk3/appdata"
  mode = 700
}

resource "system_folder" "minio" {
  path = "/mnt/disk3/appdata/minio"
  mode = 700
  depends_on = [system_folder.appdata]
}

