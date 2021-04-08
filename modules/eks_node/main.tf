data "aws_region" "current" {}

data "template_file" "user_data" {
  template = file("another_files/userdata.tpl")

  vars = {
    eks_certificate_authority = var.eks_certificate_authority
    eks_endpoint              = var.eks_endpoint
    eks_cluster_name          = var.eks_cluster_name
	  workspace 				        = var.workspace
    aws_region_current_name   = data.aws_region.current.name
  }

  depends_on = [ var.node_depens_on ]
}
