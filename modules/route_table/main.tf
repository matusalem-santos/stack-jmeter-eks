resource "aws_route_table" "rtb" {
  vpc_id = var.route_vpc_id
  
  tags = {
    Name = "${var.workspace}-${var.route_table_name}"
  }

  depends_on = [ var.rtb_depens_on ]
}