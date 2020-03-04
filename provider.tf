terraform {
  backend "s3" {}
  required_version = ">= 0.12.6"
}

provider "aws" {
  profile                 = var.aws_profile
  region                  = var.aws_region
  version                 = "= 2.38.0"
  skip_metadata_api_check = true
}
