resource "aws_route" "route" {
    route_table_id = var.rtb_id
    count = var.rtb_count
    destination_cidr_block = var.rtb_destination
    gateway_id = var.rtb_gateway
    #nat_gateway_id = var.rtb_nat_gateway
    depends_on = [ var.route_depends_on ]
}