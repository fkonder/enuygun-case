variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "enuygun-455817"
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "europe-west1"
}

variable "cluster_name" {
  description = "The name for the GKE cluster"
  default     = "enuygun-gke-cluster"
}

variable "machine_type" {
  description = "The machine type to use for the node pools"
  default     = "n2d-standard-2"
}

variable "disk_size_gb" {
  description = "The disk size in GB for the nodes"
  default     = 10
}

variable "main_pool_name" {
  description = "The name of the main node pool"
  default     = "main-pool"
}

variable "application_pool_name" {
  description = "The name of the application node pool"
  default     = "application-pool"
}

variable "smtp_password" {
  description = "SMTP password for Grafana email notifications"
  type        = string
  sensitive   = true
}

variable "notification_email" {
  description = "Email address to receive Grafana alerts"
  type        = string
  default     = "fkonderdev@hotmail.com"
}
