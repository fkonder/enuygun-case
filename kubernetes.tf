resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  
  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false

  # Disable logging and monitoring
  logging_config {
    enable_components = []
  }
  monitoring_config {
    enable_components = []
  }

  network    = "default"
  subnetwork = "default"

  node_config {
    disk_size_gb = var.disk_size_gb
  }
}

# Main node pool
resource "google_container_node_pool" "main_pool" {
  name           = var.main_pool_name
  location       = var.region
  cluster        = google_container_cluster.primary.name
  node_locations = ["${var.region}-b"] # sadece tek node çalıştırmak için -b,c,d nodeları arasından sadece birinin tercihi
  
  node_count = 1

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# Application node pool with autoscaling
resource "google_container_node_pool" "application_pool" {
  name       = var.application_pool_name
  location   = var.region
  cluster    = google_container_cluster.primary.name

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb

    labels = {
      "pool" = "application-pool"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
} 