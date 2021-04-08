# VPC
output "vpc-id" {
    value = module.vpc.id
}

output "vpc-cidr_block" {
    value = module.vpc.cidr_block
}

output "vpc-enable_dns_hostnames" {
    value = module.vpc.enable_dns_hostnames
}

output "vpc-enable_dns_support" {
    value = module.vpc.enable_dns_support
}

output "vpc-instance_tenancy" {
    value = module.vpc.instance_tenancy
}

# IGW
output "igw-id" {
    value = module.igw.id
}

output "igw-arn" {
    value = module.igw.arn
}

# Public Subnets
output "public-subnet-id" {
    value = module.public_subnet.*.id
}

output "public-subnet-arn" {
    value = module.public_subnet.*.arn
}

output "public-subnet-cidr_block" {
    value = module.public_subnet.*.cidr_block
}

output "public-subnet-map_public_ip_on_launch" {
    value = module.public_subnet.*.map_public_ip_on_launch
}


# EKS cluster
output "config_map_aws_auth" {
  value = module.eks_cluster.config_map_aws_auth
}

output "kubeconfig" {
  value = module.eks_cluster.kubeconfig
}

output "eks_certificate_authority" {
  value = module.eks_cluster.eks_certificate_authority
}

output "eks_endpoint" {
  value = module.eks_cluster.endpoint
}

output "name" {
  value = module.eks_cluster.name
}
