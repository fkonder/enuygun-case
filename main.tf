provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# create namespaces for sample app and istio

resource "kubectl_manifest" "namespace_enuygun" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: enuygun-case
YAML
}

resource "kubectl_manifest" "namespace_istio_system" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: istio-system
  labels:
    istio-injection: enabled
YAML
}

resource "kubectl_manifest" "namespace_istio_ingress" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: istio-ingress
  labels:
    istio-injection: enabled
YAML
}
