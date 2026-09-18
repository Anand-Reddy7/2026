terraform {
  required_version = ">=1.5.0"

  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }

    local = {
      source = "hashicorp/local"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://s3.jp-tok.cloud-object-storage.appdomain.cloud"
    }
    bucket = "anand-backend"
    key    = "dev/terraform.tfstate"
    region = "jp-tok"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true

    use_path_style = true
    use_lockfile   = true
  }
}