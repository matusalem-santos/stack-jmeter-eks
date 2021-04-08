resource "aws_iam_role_policy_attachment" "iam_role_policy" {
  count = length(var.role_policy_arn)
  policy_arn = "arn:aws:iam::aws:policy/${element(var.role_policy_arn, count.index )}"
  role       = var.role_name
  depends_on = [ var.role_policy_depens_on ]
}