locals {
  ksa_name      = "bucket-ksa"
  k8s_namespace = "default"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "bucket_sa_wi_missing" {
  account_id   = "${local.ksa_name}-incorrect-sa"
  display_name = "Service Account with missing IAM bindings"
  project      = var.project_id
}

resource "google_service_account" "bucket_sa_wi_correct" {
  account_id   = "${local.ksa_name}-correct-sa"
  display_name = "Service Account with correct IAM bindings"
  project      = var.project_id
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
data "google_project" "project" {}

module "project_iam_bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id, ]
  mode     = "authoritative"
  #mode     = "additive"

  bindings = {
    "roles/storage.admin" = [
      "serviceAccount:${google_service_account.bucket_sa_wi_missing.email}",
      "serviceAccount:${google_service_account.bucket_sa_wi_correct.email}",
      "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${local.k8s_namespace}/sa/${local.ksa_name}-principal"
    ]
  }
}

module "bucket_sa_wi_iam_bindings" {
  source = "terraform-google-modules/iam/google//modules/service_accounts_iam"

  service_accounts = [google_service_account.bucket_sa_wi_missing.email]
  project          = var.project_id
  mode             = "authoritative"

  bindings = {
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:${google_service_account.bucket_sa_wi_missing.email}",
      "serviceAccount:${var.project_id}.svc.id.goog[${local.k8s_namespace}/${local.ksa_name}-incorrect]"
    ]

    "roles/iam.workloadIdentityUser" = [
      "serviceAccount:${google_service_account.bucket_sa_wi_missing.email}",
    ]
  }
}

module "bucket_sa_wi_correct_iam_bindings" {
  source = "terraform-google-modules/iam/google//modules/service_accounts_iam"

  service_accounts = [google_service_account.bucket_sa_wi_correct.email]
  project          = var.project_id
  mode             = "authoritative"

  bindings = {
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:${google_service_account.bucket_sa_wi_correct.email}",
      "serviceAccount:${var.project_id}.svc.id.goog[${local.k8s_namespace}/${local.ksa_name}-correct]"
    ]

    "roles/iam.workloadIdentityUser" = [
      "serviceAccount:${google_service_account.bucket_sa_wi_correct.email}",
      "serviceAccount:${var.project_id}.svc.id.goog[${local.k8s_namespace}/${local.ksa_name}-correct]"
    ]
  }
}
