# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  alias = "impersonation"

  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

#receive short-lived access token
data "google_service_account_access_token" "default" {
  provider               = google.impersonation
  target_service_account = var.terraform_service_account
  lifetime               = "3600s"

  scopes = [
    "cloud-platform",
    "userinfo-email"
  ]
}

# default provider to use the the token
provider "google" {
  project         = var.project_id
  region          = var.region
  zone            = var.zone
  access_token    = data.google_service_account_access_token.default.access_token
  request_timeout = "60s"
}
