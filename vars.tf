

variable "env" {
    default = "dev"
}

variable "aws_region"{
    default = "us-east-1"
}

variable "vpc_cidr" {
    default = "172.35.0.0/16"
}

variable "subnet_count"{
    default = 2
}

variable "internet_cidr" {
    default = "0.0.0.0/0"
}

variable "private_rtb_name" {
    default = "private"
}

variable "public_rtb_name" {
    default = "public"
}

variable "rule_count" {
    default = 3 
}

variable "protocol" {
    default = "tcp"
}

variable "alb_ingress_controle" {
    default = [ "ALBIngressControllerIAMPolicy" ]
}

variable "cluster_policy_arn" {
    default = [ "AmazonEKSClusterPolicy", "AmazonEKSServicePolicy" ]
}

variable "node_policy_arn" {
    default = [ "service-role/AmazonEBSCSIDriverPolicy","AmazonEKSWorkerNodePolicy", "AmazonEKS_CNI_Policy", "AmazonEC2ContainerRegistryReadOnly", "AmazonSSMManagedInstanceCore"]
}

variable "ebs_csi_policy_arn" {
    default = [ "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}

variable "eks_instance_types" {
    default = ["m5.xlarge", "m4.xlarge", "c5.xlarge","c4.xlarge","r3.xlarge","r4.xlarge","t3.xlarge","t3a.xlarge", "c5a.xlarge", "m5a.xlarge"]
}

variable "workspace" {
    default = "jmeter-eks"
}