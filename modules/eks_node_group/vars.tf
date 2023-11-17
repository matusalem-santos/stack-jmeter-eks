variable "eks_cluster_name" {}

variable "node_role" {}

variable "subnets" {}

variable "desired" {
    default = 1
}

variable "max" {
    default = 2
}

variable "min" {
    default = 1
}

variable "eks_node_group_depends_on" {}

variable "eks_node_group" {
    default = "eks_node"
}

variable "inst_type" {
    default = [ "t3.medium" ]
}
variable "node_policy_attach_depends_on" {}
variable capacity_type {
  type        = string
  default     = "SPOT"
  description = "capacity_type"
}
