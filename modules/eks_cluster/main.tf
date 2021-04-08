resource "aws_eks_cluster" "eks_cluster" {
  name     = var.name
  role_arn = var.iam_cluster_arn

  vpc_config {
    security_group_ids = [ var.security_group_cluster ]
    subnet_ids         = var.subnets
  }
  depends_on = [
    var.iam_instance_profile_depends_on,
    var.cluster_ingress_node_https_depends_on,
    var.cluster_policy_attach_depends_on,
    var.public_route_depends_on
  ]
}