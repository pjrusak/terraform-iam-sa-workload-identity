# Define variables for bucket configuration
variable "project_id" {
  type        = string
  description = "The ID of the GCP project"
}

variable "region" {
  type        = string
  description = "The region where the resources will be created"
}

variable "zone" {
  type        = string
  description = "The zone where the resources will be created"
}

variable "terraform_service_account" {
  type        = string
  description = "The name of the SA to impersonate"
}

variable "gke_cluster_name" {
  type        = string
  description = "The name of the GKE cluster to be deployed"
  default     = "gke-sa-demo"
}

variable "ip_range_pods_name" {
  type        = string
  description = "The name of the IP range to be applied as secondary alias to subnetwork to be used with the GKE cluster"
  default     = "gke-sa-demo-ip-range-pods"
}

variable "ip_range_services_name" {
  type        = string
  description = "The name of the IP range to be applied as secondary alias to subnetwork to be used with the GKE cluster"
  default     = "gke-sa-demo-ip-range-svc"
}
