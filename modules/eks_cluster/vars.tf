variable "iam_cluster_arn" {}

variable "security_group_cluster" {}

variable "subnets" {}

variable "iam_node_arn" {}
variable "name" {
    description = "name do cluster eks"
}
variable "iam_instance_profile_depends_on" {}
variable "cluster_ingress_node_https_depends_on" {}
variable "cluster_policy_attach_depends_on" {}
variable "public_route_depends_on" {}