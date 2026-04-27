provider "google" {
  project = local.project_id
  region  = local.region
}

terraform {
  required_version = "= 1.14.7"

  backend "gcs" {
    bucket = "moonpay-playground-tfstate"
    prefix = "prod"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}
