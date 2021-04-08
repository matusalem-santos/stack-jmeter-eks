variable "endpoint" {
    description = "endpoint do cluster eks"
}

variable "eks_certificate_authority" {
    description = "eks_certificate_authority do cluster eks"
}

variable "name" {
    description = "name do cluster eks"
}
variable "metrics_server_version" {
  description = "The metrics-server version to use. See https://github.com/kubernetes-sigs/metrics-server/releases for available versions"
  type        = string
  default     = "0.3.6"
}

variable "k8s_pod_annotations" {
  description = "Additional annotations to be added to the Pods."
  type        = map(string)
  default     = {}
}

variable "eks_monitoring_depends_on" {}
variable "vpc_depends_on" {}
variable "eks_cluster_depends_on" {}