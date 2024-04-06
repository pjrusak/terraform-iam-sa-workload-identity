locals {
  ksa_name      = "bucket-ksa-sa"
  k8s_namespace = "default"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "bucket_sa_wi" {
  account_id   = "${local.ksa_name}-incorrect"
  display_name = "CloudSql access Service Account with wrong IAM bindings"
  project      = var.project_id
}

resource "google_service_account" "bucket_sa_wi_correct" {
  account_id   = "${local.ksa_name}-correct"
  display_name = "CloudSql access Service Account with correct IAM bindings"
  project      = var.project_id
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
module "project_iam_bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id, ]
  mode     = "authoritative"
  #mode     = "additive"

  bindings = {
    "roles/storage.admin" = [
      "serviceAccount:${google_service_account.bucket_sa_wi.email}",
      "serviceAccount:${google_service_account.bucket_sa_wi_correct.email}",
    ]
  }
}

module "bucket_sa_wi_iam_bindings" {
  source = "terraform-google-modules/iam/google//modules/service_accounts_iam"

  service_accounts = [google_service_account.bucket_sa_wi.email]
  project          = var.project_id
  mode             = "authoritative"
  #mode             = "additive"

  bindings = {
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:${google_service_account.bucket_sa_wi.email}",
      "serviceAccount:${var.project_id}.svc.id.goog[${local.k8s_namespace}/${local.ksa_name}-incorrect]"
    ]

    "roles/iam.workloadIdentityUser" = [
      "serviceAccount:${google_service_account.bucket_sa_wi.email}",
    ]
  }
}

module "bucket_sa_wi_correct_iam_bindings" {
  source = "terraform-google-modules/iam/google//modules/service_accounts_iam"

  service_accounts = [google_service_account.bucket_sa_wi.email]
  project          = var.project_id
  mode             = "authoritative"
  #mode             = "additive"

  bindings = {
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:${google_service_account.bucket_sa_wi.email}",
      "serviceAccount:${var.project_id}.svc.id.goog[${local.k8s_namespace}/${local.ksa_name}-correct]"
    ]

    "roles/iam.workloadIdentityUser" = [
      "serviceAccount:${google_service_account.bucket_sa_wi.email}",
      "serviceAccount:${var.project_id}.svc.id.goog[${local.k8s_namespace}/${local.ksa_name}-correct]"
    ]
  }
}
