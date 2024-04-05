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
