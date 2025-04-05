provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# Create monitoring namespace
resource "kubectl_manifest" "monitoring_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
YAML

  depends_on = [
    google_container_cluster.primary
  ]
}

# Create Secret for Grafana SMTP password
resource "kubectl_manifest" "grafana_smtp_secret" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: grafana-smtp-secret
  namespace: monitoring
type: Opaque
stringData:
  smtp-password: "${var.smtp_password}"
YAML

  depends_on = [
    kubectl_manifest.monitoring_namespace
  ]
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  values = [
    <<-EOT
    grafana:
      enabled: true
      adminPassword: "admin123"
      service:
        type: LoadBalancer
      
      grafana.ini:
        smtp:
          enabled: true
          host: smtp.gmail.com:587
          user: "okucukonderr@gmail.com"
          password: "${var.smtp_password}"
          from_address: "okucukonderr@gmail.com"
          from_name: "Grafana Alerts"
          starttls:
            enabled: true
          skip_verify: true
        unified_alerting:
          enabled: true

      provisioning:
        notifiers:
          - name: Default Email
            type: email
            uid: default_email
            org_id: 1
            is_default: true
            settings:
              addresses: "${var.notification_email}"

    prometheus:
      enabled: true
      serviceMonitor:
        selfMonitor: true
      prometheusSpec:
        retention: 10d
        storageSpec:
          volumeClaimTemplate:
            spec:
              accessModes: ["ReadWriteOnce"]
              resources:
                requests:
                  storage: 10Gi
    
    alertmanager:
      config:
        global:
          smtp_smarthost: 'smtp.gmail.com:587'
          smtp_from: 'okucukonderr@gmail.com'
          smtp_auth_username: 'okucukonderr@gmail.com'
          smtp_auth_password: '${var.smtp_password}'
        route:
          receiver: email-alert
        receivers:
          - name: email-alert
            email_configs:
              - to: '${var.notification_email}'
                send_resolved: true

    EOT
  ]

  depends_on = [
    kubectl_manifest.monitoring_namespace
  ]
}

resource "kubectl_manifest" "sample_app_service_monitor" {
  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: sample-app-monitor
  namespace: monitoring
  labels:
    release: kube-prometheus-stack
spec:
  selector:
    matchLabels:
      app: sample-app
  namespaceSelector:
    matchNames:
      - enuygun-case
  endpoints:
    - port: http
      interval: 15s
YAML

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}

resource "kubectl_manifest" "pod_restart_alert" {
  yaml_body = <<-YAML
    apiVersion: monitoring.coreos.com/v1
    kind: PrometheusRule
    metadata:
      name: pod-restart-rules
      namespace: monitoring
      labels:
        release: kube-prometheus-stack
    spec:
      groups:
      - name: pod.rules
        rules:
        - alert: PodRestartingFrequently
          expr: changes(kube_pod_container_status_restarts_total{namespace="enuygun-case"}[5m]) > 0
          for: 30s
          labels:
            severity: warning
          annotations:
            summary: "Pod restarting frequently (instance {{ $labels.instance }})"
            description: "Pod {{ $labels.pod }} is restarting frequently"
  YAML

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
} 