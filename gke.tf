module "gke" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"

  project_id = var.project_id
  name       = var.gke_cluster_name
  regional   = false
  region     = var.region
  zones      = [var.zone, ]

  network             = module.gcp-network.network_name
  subnetwork          = module.gcp-network.subnets_names[0]
  ip_range_pods       = var.ip_range_pods_name
  ip_range_services   = var.ip_range_services_name
  network_policy      = true
  deletion_protection = false

  create_service_account            = true
  service_account_name              = "gke-cluster-sa"
  remove_default_node_pool          = true
  disable_legacy_metadata_endpoints = true
  node_metadata                     = "GKE_METADATA"
  identity_namespace                = "enabled"

  node_pools = [
    {
      name         = "pool-01"
      machine_type = "n1-standard-2"
      autoscaling  = false
      node_count   = 2
      disk_type    = "pd-standard"
      image_type   = "COS_CONTAINERD"
      auto_upgrade = true
      auto_repair  = true
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

module "gke_service_account_iam_bindings" {
  source = "terraform-google-modules/iam/google//modules/service_accounts_iam"

  service_accounts = [module.gke.service_account]
  project          = var.project_id
  mode             = "authoritative"
  #mode             = "additive"

  bindings = {
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:${module.gke.service_account}",
      "serviceAccount:${var.terraform_service_account}",
    ]
  }
}

module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"

  project_id   = var.project_id
  location     = module.gke.location
  cluster_name = module.gke.name
}
