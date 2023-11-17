# EKS Cluster Resources

#  Create a role based on 'file_name'
module "cluster_role" {
  source = "./modules/iam_role"
  file_name = "eks-cluster-policy.json"
  role_name = "eks-cluster"
  workspace = var.workspace
}


module "cluster_policy_attach" { # Attach  policys to role
  source = "./modules/iam_role_policy_attach"
  role_policy_arn = var.cluster_policy_arn
  role_name = module.cluster_role.name
  role_policy_depens_on = module.cluster_role
}



# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
module "node_role" {
  source = "./modules/iam_role"
  file_name = "eks-node-policy.json"
  role_name = "node"
  workspace = var.workspace
}

module "node_policy_attach" {
  source = "./modules/iam_role_policy_attach"
  role_policy_arn = var.node_policy_arn
  role_name = module.node_role.name
  role_policy_depens_on = module.node_role
}

module "iam_instance_profile" {
  source = "./modules/iam_instance_profile"
  role_name = module.node_role.name
  profile_name = "eks_node_profile"
  workspace = var.workspace
}


# Cluster security group
 module "cluster_sg" {
   source = "./modules/security_group"
   env = var.env
   sg_vpc_id = module.vpc.id
   sg_name = "eks-cluster"
   sg_depens_on = module.vpc
   workspace = var.workspace
 }

 # Cluster rules
module "cluster_ingress_node_https" {
  source = "./modules/sg_rule"
  sg_rule_type = "ingress"
  sg_port_from = 443
  sg_port_to = 443
  sg_protocol = "tcp"
  ss_group_id = module.node_sg.id
  sg_id = module.cluster_sg.id
  sg_rule_depens_on = module.node_sg
}

# Node security group
 module "node_sg" {
   source = "./modules/security_group"
   env = var.env
   sg_vpc_id = module.vpc.id
   sg_name = "eks_node"
   workspace = var.workspace

   sg_depens_on = module.vpc
 }

module "node-ingress-cluster" {
  source = "./modules/sg_rule"
  sg_rule_type = "ingress"
  sg_port_from = 443
  sg_port_to = 443
  sg_protocol = "-1"
  ss_group_id = module.cluster_sg.id
  sg_id = module.node_sg.id
  sg_rule_depens_on = module.cluster_sg
}

# Creating Cluster
module "eks_cluster" {
  source = "./modules/eks_cluster"
  iam_cluster_arn = module.cluster_role.arn
  iam_node_arn = module.cluster_role.arn
  security_group_cluster = module.cluster_sg.id
  subnets = module.public_subnet.id
  name= var.workspace
  iam_instance_profile_depends_on = module.iam_instance_profile
  cluster_ingress_node_https_depends_on = module.cluster_ingress_node_https
  cluster_policy_attach_depends_on = module.cluster_policy_attach
  public_route_depends_on = module.public_route
}

module "eks_node_group" {
  source = "./modules/eks_node_group"
  eks_cluster_name = module.eks_cluster.name
  node_role = module.node_role.arn
  subnets = [module.public_subnet.id[0]]
  eks_node_group_depends_on = module.eks_cluster
  inst_type = var.eks_instance_types
  min = 1
  max = 8
  desired = 3
  node_policy_attach_depends_on = module.node_policy_attach
}

module "eks_cluster_addons" {
  source = "./modules/eks_cluster_addons"
  eks_cluster_addons_depends_on = module.eks_node_group
  cluster_name= var.workspace
  cluster_addons = var.cluster_addons
}
module "eks_application" {
  source = "./modules/eks_application"
  name       = module.eks_cluster.name
  endpoint   = module.eks_cluster.endpoint
  eks_certificate_authority = module.eks_cluster.eks_certificate_authority
  eks_application_depends_on = module.eks_node_group
  vpc_depends_on = module.public_rtb_assoc
  eks_cluster_depends_on = module.eks_cluster
  eks_cluster_addons_depends_on = module.eks_cluster_addons
}

resource "null_resource" "outputs" {
  triggers = {
    always_run = timestamp()
  }
}

