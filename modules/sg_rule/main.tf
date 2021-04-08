resource "aws_security_group_rule" "sc_sg_rule" {
  count = var.cidr == null ? 1 : 0
  type = var.sg_rule_type
  from_port = var.sg_port_from
  to_port = var.sg_port_to
  protocol = var.sg_protocol
  source_security_group_id = var.sg_id
  security_group_id = var.sg_id
  
  depends_on = [ var.sg_rule_depens_on ]
}

resource "aws_security_group_rule" "sg_rule" {
  count = var.cidr == null ? 0 : 1
  type = var.sg_rule_type
  from_port = var.sg_port_from
  to_port = var.sg_port_to
  protocol = var.sg_protocol
  cidr_blocks = [ var.cidr ]
  security_group_id = var.sg_id

  depends_on = [ var.sg_rule_depens_on ]
}