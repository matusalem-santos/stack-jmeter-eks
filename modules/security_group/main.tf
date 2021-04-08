resource "aws_security_group" "sg" {
  name        = "${var.workspace}-${var.sg_name}-${var.env}"
  vpc_id      = var.sg_vpc_id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
        Name = "${var.workspace}-${var.sg_name}"
    }

    depends_on = [ var.sg_depens_on ]
}