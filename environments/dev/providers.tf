provider "aws" {
  region = local.main_region

  assume_role {
    role_arn     = ""
    session_name = "Terraform"
  }

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"

  assume_role {
    role_arn     = ""
    session_name = "Terraform"
  }

  default_tags {
    tags = local.common_tags
  }
}

# provider "datadog" {
#   api_key = var.datadog_api_key
#   app_key = var.datadog_app_key
# }
