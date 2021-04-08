
provider "kubernetes" {
  host                   = var.endpoint
  cluster_ca_certificate = base64decode(var.eks_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.name]
    command     = "aws"
  }
}

locals {
  k8s_namespace               = "kube-system"
  k8s_pod_annotations         = var.k8s_pod_annotations
  metrics_server_docker_image = "k8s.gcr.io/metrics-server-amd64:v${var.metrics_server_version}"
  metrics_server_version      = var.metrics_server_version
}

resource "kubernetes_cluster_role" "aggregated_metrics_reader" {
  metadata {
    labels = {
      "app.kubernetes.io/name"                       = "metrics-server"
      "app.kubernetes.io/managed-by"                 = "terraform"
      "rbac.authorization.k8s.io/aggregate-to-view"  = "true"
      "rbac.authorization.k8s.io/aggregate-to-edit"  = "true"
      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
    }
    name = "system:aggregated-metrics-reader"
  }
  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
depends_on = [ var.eks_monitoring_depends_on,
                var.vpc_depends_on,
                var.eks_cluster_depends_on
            ]
}

resource "kubernetes_cluster_role_binding" "auth_delegator" {
  metadata {
    labels = {
      "app.kubernetes.io/name"       = "metrics-server"
      "app.kubernetes.io/managed-by" = "terraform"
    }
    name = "metrics-server:system:auth-delegator"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_service_account.this.metadata[0].namespace
  }
depends_on = [ var.eks_monitoring_depends_on,
               var.vpc_depends_on,
               var.eks_cluster_depends_on
            ]
}

resource "kubernetes_role_binding" "metrics_server_auth_reader" {
  metadata {
    labels = {
      "app.kubernetes.io/name"       = "metrics-server"
      "app.kubernetes.io/managed-by" = "terraform"
    }
    name      = "metrics-server:system:auth-delegator"
    namespace = local.k8s_namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "extension-apiserver-authentication-reader"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_service_account.this.metadata[0].namespace
  }
depends_on = [ var.eks_monitoring_depends_on,
               var.vpc_depends_on,
               var.eks_cluster_depends_on
            ]
}

resource "kubernetes_api_service" "this" {
  metadata {
    labels = {
      "app.kubernetes.io/name"       = "metrics-server"
      "app.kubernetes.io/managed-by" = "terraform"
    }
    name = "v1beta1.metrics.k8s.io"
  }
  spec {
    service {
      name      = kubernetes_service.this.metadata[0].name
      namespace = kubernetes_service.this.metadata[0].namespace
    }
    group                    = "metrics.k8s.io"
    version                  = "v1beta1"
    insecure_skip_tls_verify = true
    group_priority_minimum   = 100
    version_priority         = 100
  }
depends_on = [ var.eks_monitoring_depends_on,
               var.vpc_depends_on,
               var.eks_cluster_depends_on
            ]
}

resource "kubernetes_service_account" "this" {
  automount_service_account_token = true
  metadata {
    labels = {
      "app.kubernetes.io/name"       = "metrics-server"
      "app.kubernetes.io/managed-by" = "terraform"
    }
    name      = "metrics-server"
    namespace = local.k8s_namespace
  }
depends_on = [ var.eks_monitoring_depends_on,
               var.vpc_depends_on,
               var.eks_cluster_depends_on
            ]
}

resource "kubernetes_deployment" "this" {
  depends_on = [
    kubernetes_cluster_role_binding.auth_delegator,
    kubernetes_role_binding.metrics_server_auth_reader,
    kubernetes_cluster_role_binding.this,
    var.eks_monitoring_depends_on,
    var.eks_cluster_depends_on,
    var.vpc_depends_on
  ]

  metadata {
    name      = "metrics-server"
    namespace = local.k8s_namespace

    labels = {
      "app.kubernetes.io/name"       = "metrics-server"
      "app.kubernetes.io/version"    = "v${local.metrics_server_version}"
      "app.kubernetes.io/managed-by" = "terraform"
      "k8s-app"                      = "metrics-server"
    }

    annotations = {
      "field.cattle.io/description" = "metrics-server"
    }
  }

  spec {

    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "metrics-server"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        annotations = local.k8s_pod_annotations
        labels = {
          "app.kubernetes.io/name"    = "metrics-server"
          "app.kubernetes.io/version" = local.metrics_server_version
          "k8s-app"                   = "metrics-server"
        }
      }

      spec {
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = ["metrics-server"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        automount_service_account_token = true

        dns_policy = "ClusterFirst"

        restart_policy = "Always"

        container {
          args = [
            "--logtostderr",
            "--cert-dir=/tmp",
            "--secure-port=4443",
            "--kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP"
          ]

          command = [
            "/metrics-server"
          ]

          image             = local.metrics_server_docker_image
          image_pull_policy = "IfNotPresent"

          name = "metrics-server"

          termination_message_path = "/dev/termination-log"

          port {
            name           = "main-port"
            container_port = 4443
            protocol       = "TCP"
          }

          security_context {
            read_only_root_filesystem = true
            run_as_non_root           = true
            run_as_user               = 1000
          }
          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        priority_class_name = "system-node-critical"

        service_account_name             = kubernetes_service_account.this.metadata[0].name
        termination_grace_period_seconds = 60

        volume {
          name = "tmp-dir"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = "metrics-server"
    namespace = local.k8s_namespace

    labels = {
      "app.kubernetes.io/name"        = "metrics-server"
      "app.kubernetes.io/managed-by"  = "terraform"
      "k8s-app"                       = "metrics-server"
      "kubernetes.io/name"            = "Metrics-server"
      "kubernetes.io/cluster-service" = "true"
    }

    annotations = {
      "field.cattle.io/description" = "metrics-server"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "metrics-server"
    }
    port {
      port        = 443
      protocol    = "TCP"
      target_port = "main-port"
    }
  }
  depends_on = [ var.eks_monitoring_depends_on,
                var.vpc_depends_on,
                var.eks_cluster_depends_on
              ]
}

resource "kubernetes_cluster_role" "this" {
  metadata {
    name = "system:metrics-server"

    labels = {
      "app.kubernetes.io/name"       = "metrics-server"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  rule {
    api_groups = [""]
    resources = [
      "pods",
      "nodes",
      "nodes/stats",
      "namespaces",
      "configmaps"
    ]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }
  depends_on = [ var.eks_monitoring_depends_on,
                var.vpc_depends_on,
                var.eks_cluster_depends_on
              ]
}

resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name = "system:metrics-server"

    labels = {
      "app.kubernetes.io/name"       = "metrics-server"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this.metadata[0].name
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_service_account.this.metadata[0].namespace
  }
  depends_on = [ var.eks_monitoring_depends_on,
                var.vpc_depends_on,
                var.eks_cluster_depends_on
              ]
}


provider "helm" {
  alias = "my_cluster"
  kubernetes {
    host                   = var.endpoint
    cluster_ca_certificate = base64decode(var.eks_certificate_authority)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.name]
      command     = "aws"
    }
  }
}
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
  depends_on = [ var.eks_monitoring_depends_on,
                var.vpc_depends_on,
                var.eks_cluster_depends_on
              ]
}

resource "helm_release" "prometheus-operator" {
  provider  = helm.my_cluster
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata.0.name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [
    file("${path.module}/prometheus-values.yaml")
  ]
  depends_on = [kubernetes_namespace.monitoring]
}
