resource "helm_release" "istio_base" {
  name       = "istio-base"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.17.0"
  depends_on = [kubectl_manifest.namespace_istio_system]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.17.0"
  values = [
    <<EOF
    global:
      istioNamespace: istio-system
    pilot:
      enabled: true
    EOF
  ]
  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  namespace  = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.17.0"
  values = [
    <<EOF
    service:
      ports:
        - port: 80
          targetPort: 80
          name: http2
        - port: 443
          targetPort: 443
          name: https
    EOF
  ]
  depends_on = [helm_release.istiod, kubectl_manifest.namespace_istio_ingress]
}

resource "helm_release" "istio_egress" {
  name       = "istio-egress"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.17.0"
  values = [
    <<EOF
    service:
      type: ClusterIP
      ports:
        - port: 80
          targetPort: 80
          name: http2
        - port: 443
          targetPort: 443
          name: https
    EOF
  ]
  depends_on = [helm_release.istiod]
} 