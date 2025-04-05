provider "kubectl" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  load_config_file       = false
}

data "google_client_config" "default" {}

resource "kubectl_manifest" "sample_app_deployment" {
  yaml_body = file("${path.module}/k8s/sample-app/deployment.yaml")

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.application_pool,
    kubectl_manifest.namespace_enuygun
  ]
}

resource "kubectl_manifest" "sample_app_service" {
  yaml_body = file("${path.module}/k8s/sample-app/service.yaml")

  depends_on = [
    kubectl_manifest.sample_app_deployment
  ]
}

# hpa for 1 to 3 nodes
# resource "kubectl_manifest" "sample_app_hpa" {
#   yaml_body = file("${path.module}/k8s/sample-app/hpa.yaml")
# 
#   depends_on = [
#     kubectl_manifest.sample_app_deployment
#   ]
# }

# Load generator for testing hpa and keda
# resource "kubectl_manifest" "load_generator" {
#   yaml_body = file("${path.module}/k8s/sample-app/load-generator.yaml")
# 
#   depends_on = [
#     kubectl_manifest.sample_app_service
#   ]
# }