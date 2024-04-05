# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "cloudsql-sa" {
  account_id = "cloudsql-sa"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "instanceuser-sa" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"

  member = "serviceAccount:${google_service_account.cloudsql-sa.email}"
}

resource "google_project_iam_member" "instanceclient-sa" {
  project = var.project_id
  role    = "roles/cloudsql.client"

  member = "serviceAccount:${google_service_account.cloudsql-sa.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam
resource "google_service_account_iam_binding" "serviceaccountuser-sa" {
  service_account_id = google_service_account.cloudsql-sa.id
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.cloudsql-sa.email}",
    "serviceAccount:${var.project_id}.svc.id.goog[default/cloudsql-sa]"
  ]
}

resource "google_service_account_iam_binding" "workloadidentityuser-sa" {
  service_account_id = google_service_account.cloudsql-sa.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${google_service_account.cloudsql-sa.email}",
  ]
  #  member             = ["serviceAccount:${google_service_account.cloudsql-sa.email}", "serviceAccount:${var.project_id}.svc.id.goog[default/cloudsql-sa]"]
  #  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/cloudsql-sa]"
}
