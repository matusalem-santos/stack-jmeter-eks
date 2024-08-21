#data "aws_availability_zones" "available" {}
locals {
  aws_availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
}

resource "aws_subnet" "aws_subnet" {
    vpc_id                  = var.vpc_id
    cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index + var.subnet_cidr_block)
    availability_zone       = local.aws_availability_zones[count.index]
    map_public_ip_on_launch = var.public_ip
    count = var.subnet_count  
    
    tags = {
        Name = "${var.workspace}-${var.subnet_name}-${count.index + 1}-${var.env}"
        Environment = var.workspace
        "kubernetes.io/cluster/${var.workspace}" = "shared"
        "kubernetes.io/role/${ var.public_ip ? "elb" : "internal-elb" }" = 1
    }

    depends_on = [ var.subnet_depens_on ]
}