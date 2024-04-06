locals {
  network    = "${var.gke_cluster_name}-network"
  subnetwork = "${var.gke_cluster_name}-subnetwork-${var.region}"
}

module "gcp-network" {
  source = "terraform-google-modules/network/google"

  project_id              = var.project_id
  network_name            = local.network
  auto_create_subnetworks = false

  subnets = [
    {
      subnet_name   = local.subnetwork
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (local.subnetwork) = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}
