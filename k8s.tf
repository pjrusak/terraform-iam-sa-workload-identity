data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

resource "kubernetes_service_account" "ksa_wi_principal" {
  metadata {
    name      = "${local.ksa_name}-principal"
    namespace = local.k8s_namespace
  }
}

resource "kubernetes_service_account" "ksa_wi_missing" {
  metadata {
    name      = "${local.ksa_name}-missing"
    namespace = local.k8s_namespace

    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.bucket_sa_wi_missing.email
    }
  }
}

resource "kubernetes_service_account" "ksa_wi_correct" {
  metadata {
    name      = "${local.ksa_name}-correct"
    namespace = local.k8s_namespace

    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.bucket_sa_wi_correct.email
    }
  }
}

resource "kubernetes_pod" "wi-bucket-ksa-missing-pod" {
  metadata {
    name      = "wi-${local.ksa_name}-missing-pod"
    namespace = local.k8s_namespace
  }

  spec {
    container {
      image   = "google/cloud-sdk:slim"
      name    = "wi-${local.ksa_name}-missing"
      command = ["sleep", "infinity"]
    }

    node_selector = {
      "iam.gke.io/gke-metadata-server-enabled" = "true"
      "node_pool"                              = "pool-01"
    }

    service_account_name = split("/", kubernetes_service_account.ksa_wi_missing.id).1
  }
}

resource "kubernetes_pod" "wi-bucket-ksa-correct-pod" {
  metadata {
    name      = "wi-${local.ksa_name}-correct-pod"
    namespace = local.k8s_namespace
  }

  spec {
    container {
      image   = "google/cloud-sdk:slim"
      name    = "wi-${local.ksa_name}-correct"
      command = ["sleep", "infinity"]
    }

    node_selector = {
      "iam.gke.io/gke-metadata-server-enabled" = "true"
      "node_pool"                              = "pool-01"
    }

    service_account_name = split("/", kubernetes_service_account.ksa_wi_correct.id).1
  }
}

resource "kubernetes_pod" "wi-bucket-ksa-principal-pod" {
  metadata {
    name      = "wi-${local.ksa_name}-principal-pod"
    namespace = local.k8s_namespace
  }

  spec {
    container {
      image   = "google/cloud-sdk:slim"
      name    = "wi-${local.ksa_name}-principal"
      command = ["sleep", "infinity"]
    }

    node_selector = {
      "iam.gke.io/gke-metadata-server-enabled" = "true"
      "node_pool"                              = "pool-01"
    }

    service_account_name = split("/", kubernetes_service_account.ksa_wi_principal.id).1
  }
}
