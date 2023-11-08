
module "eks_monitoring"{
    source = "./eks_monitoring"
    name       = var.name
    endpoint   = var.endpoint
    eks_certificate_authority = var.eks_certificate_authority
    eks_monitoring_depends_on = var.eks_application_depends_on
    vpc_depends_on = var.vpc_depends_on
    eks_cluster_depends_on = var.eks_cluster_depends_on
    eks_cluster_addons_depends_on = var.eks_cluster_addons_depends_on
}

module "eks_jmeter"{
    source = "./eks_jmeter"
    name       = var.name
    endpoint   = var.endpoint
    eks_certificate_authority = var.eks_certificate_authority
    eks_application_depends_on = var.eks_application_depends_on
    vpc_depends_on = var.vpc_depends_on
    eks_cluster_depends_on = var.eks_cluster_depends_on
    eks_cluster_addons_depends_on = var.eks_cluster_addons_depends_on
}
