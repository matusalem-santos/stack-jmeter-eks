data "aws_availability_zones" "available" {}

resource "aws_subnet" "aws_subnet" {
    vpc_id                  = var.vpc_id
    cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index + var.subnet_cidr_block)
    availability_zone       = data.aws_availability_zones.available.names[count.index]
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