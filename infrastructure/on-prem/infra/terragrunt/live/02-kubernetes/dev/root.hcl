remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket         = "klustered.us"
    key            = "01-k3s-cluster/${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "klustered.us-lock-table"
  }
}