variable "endpoint" {
    description = "endpoint do cluster eks"
}

variable "eks_certificate_authority" {
    description = "eks_certificate_authority do cluster eks"
}

variable "name" {
    description = "name do cluster eks"
}

variable "eks_application_depends_on" {}
variable "vpc_depends_on" {}
variable "eks_cluster_depends_on" {}