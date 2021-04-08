resource "aws_launch_configuration" "lc" {
  associate_public_ip_address = true
  iam_instance_profile        = var.lc_instance_profile
  image_id                    = var.lc_image_id
  instance_type               = var.lc_instance_type
  name_prefix                 = var.workspace
  key_name                    = var.key
  security_groups             = [ var.security_group_node ]
  user_data                   = var.data_of_user
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ var.lc_depens_on ]
}