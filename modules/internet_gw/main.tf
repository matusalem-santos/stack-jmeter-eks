resource "aws_internet_gateway" "igw" {
    vpc_id = var.igw_vpc_id
    tags = {
        Name = "${ var.workspace}-${var.igw_name}-${var.env}"
    }
}