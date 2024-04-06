locals {
  ksa_name      = "bucket-ksa-sa"
  k8s_namespace = "default"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "bucket_sa" {
  account_id   = local.ksa_name
  display_name = "CloudSql access Service Account"
  project      = var.project_id
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
module "project-iam-bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id, ]
  mode     = "authoritative"
  #mode     = "additive"

  bindings = {
    "roles/storage.admin" = [
      "serviceAccount:${google_service_account.bucket_sa.email}",
    ]
  }
}

module "service_account-iam-bindings" {
  source = "terraform-google-modules/iam/google//modules/service_accounts_iam"

  service_accounts = [google_service_account.bucket_sa.email]
  project          = var.project_id
  mode             = "authoritative"
  #mode             = "additive"

  bindings = {
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:${google_service_account.bucket_sa.email}",
      "serviceAccount:${var.project_id}.svc.id.goog[${local.k8s_namespace}/${local.ksa_name}]"
    ]

    "roles/iam.workloadIdentityUser" = [
      "serviceAccount:${google_service_account.bucket_sa.email}",
    ]
  }
}
