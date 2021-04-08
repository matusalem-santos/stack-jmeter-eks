resource "aws_route_table_association" "rtb_assoc" {
    count = var.sub_id == null ? 1 : length(var.sub_id)
    subnet_id = var.sub_id[count.index]
    route_table_id = var.rtb_id   
    depends_on = [var.assoc_depends_on]
}