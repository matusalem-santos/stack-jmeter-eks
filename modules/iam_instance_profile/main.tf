resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "${var.workspace}-${var.profile_name}"
  role = var.role_name
}