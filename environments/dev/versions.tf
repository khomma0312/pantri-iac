terraform {
  required_version = "~> 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.52.0"
    }

    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}
