locals {
  cloudsql_sa_name = "cloudsql-sa"
  k8s_namespace    = "default"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "cloudsql_sa" {
  account_id   = local.cloudsql_sa_name
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
    "roles/cloudsql.instanceUser" = [
      "serviceAccount:${google_service_account.cloudsql_sa.email}",
    ]

    "roles/cloudsql.client" = [
      "serviceAccount:${google_service_account.cloudsql_sa.email}",
    ]
  }
}

module "service_account-iam-bindings" {
  source = "terraform-google-modules/iam/google//modules/service_accounts_iam"

  service_accounts = [google_service_account.cloudsql_sa.email]
  project          = var.project_id
  mode             = "authoritative"
  #mode             = "additive"

  bindings = {
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:${google_service_account.cloudsql_sa.email}",
      "serviceAccount:${var.project_id}.svc.id.goog[${local.k8s_namespace}/${local.cloudsql_sa_name}]"
    ]

    "roles/iam.workloadIdentityUser" = [
      "serviceAccount:${google_service_account.cloudsql_sa.email}",
    ]
  }
}
