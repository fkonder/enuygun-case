resource "helm_release" "keda" {
  name       = "keda"
  namespace  = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  version    = "2.12.0"

  values = [
    <<EOF
    podAnnotations:
      prometheus.io/scrape: "true"
      prometheus.io/port: "8080"
    EOF
  ]
}


resource "kubectl_manifest" "keda_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: keda
YAML
}

# keda config, %25 cpu load 1 to 3 node update
resource "kubectl_manifest" "keda_scaled_object" {
  yaml_body = <<YAML
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: sample-app-scaledobject
  namespace: enuygun-case
spec:
  scaleTargetRef:
    name: sample-app
    kind: Deployment
  minReplicaCount: 1
  maxReplicaCount: 3
  triggers:
  - type: cpu
    metadata:
      type: Utilization
      value: "25"
YAML

  depends_on = [
    helm_release.keda,
    kubectl_manifest.namespace_enuygun
  ]
} 