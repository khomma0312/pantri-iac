terraform {
  backend "s3" {
    bucket  = "pantri-terraform-state-dev"
    key     = "environments/dev/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
