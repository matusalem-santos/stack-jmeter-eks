

provider "kubernetes" {
  host                   = var.endpoint
  cluster_ca_certificate = base64decode(var.eks_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.name]
    command     = "aws"
  }
}

# Create a local variable for the load balancer name.
locals {
  reporter_lb_hostname = kubernetes_service.jmeter-reporter.status.0.load_balancer.0.ingress.0.hostname
}

data "template_file" "grafana-dashboard-jmeter" {
  template = file("${path.module}/grafana-jmeter-dashboard.json")
  vars = {
    reporter_lb_name = local.reporter_lb_hostname
  }
}

# Creating Namespace: jmeter
resource "kubernetes_namespace" "jmeter" {
    metadata {
        name = "jmeter"
    }
    depends_on = [
        var.eks_application_depends_on,
        var.vpc_depends_on,
        var.eks_cluster_depends_on
    ]
}

resource "kubernetes_persistent_volume_claim" "jmeter-pvc" {
    metadata {
        name = "jmeter-pvc"
        namespace = kubernetes_namespace.jmeter.metadata.0.name
    }
    spec {
        access_modes = ["ReadWriteOnce"]
        resources {
            requests = {
                storage = "1Gi"
            }
        }
        storage_class_name = "gp2"
    }
}

# Creating Jmeter Slaves
resource "kubernetes_deployment" "jmeter-slaves" {

    metadata {
        name      = "jmeter-slaves"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "jmeter_mode"= "slave"
        }
    }

    spec {

        replicas = 2

        selector {
            match_labels = {
                "jmeter_mode"= "slave"
            }
        }

        template {
            metadata {
                labels = {
                    "jmeter_mode"= "slave"
                }
            }

            spec {

                container {

                    image             = "matus258/jmeter-slave:latest"
                    image_pull_policy   = "IfNotPresent"
                    name = "jmslave"
                    port {
                        container_port = 1099
                        protocol       = "TCP"
                    }
                    port {
                        container_port = 50000
                        protocol       = "TCP"
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "jmeter-slaves-svc" {
    metadata {
        name      = "jmeter-slaves-svc"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "jmeter_mode" = "slave"
        }
    }

    spec {
        selector = {
            "jmeter_mode" = "slave"
        }

        cluster_ip = "None"

        port {
            name = "first"
            port        = 1099
            target_port = 1099
        }
        port {
            name = "second"
            port        = 50000
            target_port = 50000
        }
    }
}

# Creating Jmeter Master
resource "kubernetes_config_map" "jmeter-load-test" {
    metadata {
        name = "jmeter-load-test"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "app"= "influxdb-jmeter"
        }
    }

  data = {
    "load_test" = file("${path.module}/load_test")
  }

}

resource "kubernetes_deployment" "jmeter-master" {

    metadata {
        name      = "jmeter-master"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "jmeter_mode"= "master"
        }
    }

    spec {

        replicas = 1

        selector {
            match_labels = {
                "jmeter_mode"= "master"
            }
        }

        template {
            metadata {
                labels = {
                    "jmeter_mode"= "master"
                }
            }

            spec {

                container {

                    image             = "matus258/jmeter-master:latest"
                    image_pull_policy   = "IfNotPresent"
                    name = "jmmaster"
                    command = [ "/bin/bash", "-c", "--" ]
                    args = [ "while true; do sleep 30; done;" ]
                    volume_mount {
                        name = "loadtest"
                        mount_path = "/load_test"
                        sub_path = "load_test"
                    }
                    port {
                        container_port = 60000
                        protocol       = "TCP"
                    }
                }
                volume {
                    name = "loadtest"
                    config_map {
                        name = "jmeter-load-test"
                    }
                }
            }
        }
    }
}

# Creating Influxdb
resource "kubernetes_secret" "influxdb-secret" {
    metadata {
        name = "influxdb-creds"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "app"= "influxdb-jmeter"
        }
    }

    data = {
        INFLUXDB_DB="jmeterdb"
        INFLUXDB_USER="grafana"
        INFLUXDB_USER_PASSWORD="grafana"
    }

    type = "Opaque"

}

resource "kubernetes_deployment" "influxdb-jmeter" {

    metadata {
        name      = "influxdb-jmeter"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "app"= "influxdb-jmeter"
        }
    }

    spec {

        replicas = 1

        selector {
            match_labels = {
                "app"= "influxdb-jmeter"
            }
        }

        template {
            metadata {
                labels = {
                    "app"= "influxdb-jmeter"
                }
            }

            spec {

                container {

                    image             = "influxdb:1.8"
                    image_pull_policy   = "IfNotPresent"
                    name = "influxdb"
                    env_from {
                        secret_ref {
                            name = "influxdb-creds"
                        }
                    }

                    port {
                        name           = "influx"
                        container_port = 8083
                        protocol       = "TCP"
                    }
                    port {
                        name           = "api"
                        container_port = 8086
                        protocol       = "TCP"
                    }
                    port {
                        name           = "graphite"
                        container_port = 2003
                        protocol       = "TCP"
                    }

                    volume_mount {
                      name = "var-lib-influxdb"
                      mount_path = "/var/lib/influxdb"
                    }
                }
                volume {
                    name = "var-lib-influxdb"
                    persistent_volume_claim {
                        claim_name = "jmeter-pvc"
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "jmeter-influxdb" {
    metadata {
        name      = "jmeter-influxdb"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "app"= "influxdb-jmeter"
        }
    }

    spec {
        selector = {
            "app"= "influxdb-jmeter"
        }
        port {
            name = "http"
            port        = 8083
            target_port = 8083
        }
        port {
            name = "api"
            port        = 8086
            target_port = 8086
        }
        port {
            name = "graphite"
            port        = 2003
            target_port = 2003
        }
    }
}

# Creating Grafana
resource "kubernetes_config_map" "grafana-influxdb-datasource" {
    metadata {
        name = "grafana-influxdb-datasource"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "app"= "grafana-jmeter-configs"
        }
    }

  data = {
    "influxdb-datasource.yml" = file("${path.module}/influxdb-datasource.yml")
  }

}
resource "kubernetes_config_map" "grafana-dashboard-provider" {
    metadata {
        name = "grafana-dashboard-provider"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "app"= "grafana-jmeter-configs"
        }
    }

  data = {
    "grafana-dashboard-provider.yml" = file("${path.module}/grafana-dashboard-provider.yml")
  }

}
resource "kubernetes_config_map" "grafana-jmeter-dashboard" {
    metadata {
        name = "grafana-jmeter-dashboard"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "app"= "grafana-jmeter-configs"
        }
    }

    data = {
        "grafana-jmeter-dashboard.json" = data.template_file.grafana-dashboard-jmeter.rendered
    }

}
resource "kubernetes_deployment" "jmeter-grafana" {

    metadata {
        name      = "jmeter-grafana"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "app"="jmeter-grafana"
        }
    }

    spec {

        replicas = 1

        selector {
            match_labels = {
                "app" = "jmeter-grafana"
            }
        }

        template {
            metadata {
                labels = {
                    "app" = "jmeter-grafana"
                }
            }

            spec {

                volume {
                    name = "grafana-influxdb-datasource"
                    config_map {
                        name = "grafana-influxdb-datasource"
                    }
                }
                volume {
                    name = "grafana-dashboard-provider"
                    config_map {
                        name = "grafana-dashboard-provider"
                    }
                }
                volume {
                    name = "grafana-jmeter-dashboard"
                    config_map {
                        name = "grafana-jmeter-dashboard"
                    }
                }


                container {

                    image             = "grafana/grafana:7.3.0"
                    image_pull_policy = "IfNotPresent"

                    name = "grafana"

                    port {
                        name           = "grafana-port"
                        container_port = 3000
                        protocol       = "TCP"
                    }
                    env {
                        name = "GF_AUTH_BASIC_ENABLED"
                        value = "true"
                    }
                    env {
                        name = "GF_AUTH_ANONYMOUS_ENABLED"
                        value = "true"
                    }
                    env {
                        name = "GF_USERS_ALLOW_ORG_CREATE"
                        value = "true"
                    }
                    env {
                        name = "GF_AUTH_ANONYMOUS_ORG_ROLE"
                        value = "Admin"
                    }
                    env {
                        name = "GF_SERVER_ROOT_URL"
                        value = "/"
                    }
                    env {
                        name = "GF_SECURITY_ADMIN_USER"
                        value = "admin"
                    }
                    env {
                        name = "GF_SECURITY_ADMIN_PASSWORD"
                        value = "grafana"
                    }
                    env {
                        name = "GF_RENDERING_SERVER_URL"
                        value = "http://grafana-renderer:8081/render"
                    }
                    env {
                        name = "GF_RENDERING_CALLBACK_URL"
                        value = "http://jmeter-grafana:3000/"
                    }
                    env {
                        name = "GF_LOG_FILTERS"
                        value = "rendering:debug"
                    }
                    env {
                        name = "TZ"
                        value = "America/Sao_Paulo"
                    }
                    volume_mount {
                        mount_path = "/etc/grafana/provisioning/datasources/influxdb-datasource.yml"
                        name = "grafana-influxdb-datasource"
                        sub_path = "influxdb-datasource.yml"
                        read_only = true
                    }
                    volume_mount {
                        mount_path = "/etc/grafana/provisioning/dashboards/grafana-dashboard-provider.yml"
                        name = "grafana-dashboard-provider"
                        sub_path = "grafana-dashboard-provider.yml"
                        read_only = true
                    }
                    volume_mount {
                        mount_path = "/var/lib/grafana/dashboards/grafana-jmeter-dashboard.json"
                        name = "grafana-jmeter-dashboard"
                        sub_path = "grafana-jmeter-dashboard.json"
                        read_only = true
                    }
            
                }
            }
        }
    }
}

resource "kubernetes_service" "jmeter-grafana" {
    metadata {
        name      = "jmeter-grafana"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "app"="jmeter-grafana"
        }
    }

    spec {
        selector = {
            "app" = "jmeter-grafana"
        }
        port {
            port        = 3000
            target_port = 3000
        }

        type = "LoadBalancer"
    }
}

resource "kubernetes_deployment" "grafana-renderer" {

    metadata {
        name      = "grafana-renderer"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "app"="grafana-renderer"
        }
    }

    spec {

        replicas = 1

        selector {
            match_labels = {
                "app" = "grafana-renderer"
            }
        }

        template {
            metadata {
                labels = {
                    "app" = "grafana-renderer"
                }
            }

            spec {
                container {

                    image             = "grafana/grafana-image-renderer:latest"
                    image_pull_policy = "IfNotPresent"

                    name = "grafana-renderer"

                    port {
                        name           = "renderer-port"
                        container_port = 8081
                        protocol       = "TCP"
                    }
                    env {
                        name = "ENABLE_METRICS"
                        value = "true"
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "grafana-renderer" {
    metadata {
        name      = "grafana-renderer"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "app"="grafana-renderer"
        }
    }

    spec {
        selector = {
            "app" = "grafana-renderer"
        }
        port {
            port        = 8081
            target_port = 8081
        }
    }
}

resource "kubernetes_deployment" "jmeter-reporter" {

    metadata {
        name      = "jmeter-reporter"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "jmeter_mode"="reporter"
        }
    }

    spec {

        replicas = 1

        selector {
            match_labels = {
                "jmeter_mode"="reporter"
            }
        }

        template {
            metadata {
                labels = {
                    "jmeter_mode"="reporter"
                }
            }

            spec {

                container {

                    image             = "izakmarais/grafana-reporter:latest"

                    name = "jmreporter"
                    command = [ "/usr/local/bin/grafana-reporter","-ip","jmeter-grafana:3000" ]
                    port {
                        name           = "reporter-port"
                        container_port = 8686
                        protocol       = "TCP"
                    }
                    env {
                        name = "TZ"
                        value = "America/Sao_Paulo"
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "jmeter-reporter" {
    metadata {
        name      = "jmeter-reporter"
        namespace = kubernetes_namespace.jmeter.metadata.0.name

        labels = {
            "jmeter_mode"="reporter"
        }
    }

    spec {
        selector = {
            "jmeter_mode"="reporter"
        }
        port {
            port        = 8686
            target_port = 8686
        }

        type = "LoadBalancer"
    }
}