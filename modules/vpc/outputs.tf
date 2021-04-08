output "id" {
    value = aws_vpc.vpc.id
}

output "cidr_block" {
    value = aws_vpc.vpc.cidr_block
}

output "enable_dns_hostnames" {
    value = aws_vpc.vpc.enable_dns_hostnames
}

output "enable_dns_support" {
    value = aws_vpc.vpc.enable_dns_support
}

output "instance_tenancy" {
    value = aws_vpc.vpc.instance_tenancy
}