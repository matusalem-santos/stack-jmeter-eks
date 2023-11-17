resource "aws_eks_node_group" "node" {
  cluster_name    = var.eks_cluster_name
  node_group_name = "jmeter-eks-node"
  node_role_arn   = var.node_role
  subnet_ids      = var.subnets
  instance_types = var.inst_type
  capacity_type   = var.capacity_type

  tags = {
    Name = "jmeter-eks-node"
  }
  scaling_config {
    desired_size = var.desired
    max_size     = var.max
    min_size     = var.min
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [ var.eks_node_group_depends_on,
                var.node_policy_attach_depends_on
              ]
}