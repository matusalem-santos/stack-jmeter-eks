
variable "cluster_name" {
    description = "name do cluster eks"
}

variable "cluster_addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type        = any
  default     = {}
}

variable eks_cluster_addons_depends_on {}
