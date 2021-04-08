
variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  description = "Secret key da conta que sera provisionado o ambiente, variável mantida pelo Terraform Cloud"
}

variable "AWS_ACCESS_KEY_ID" {
  type        = string
  description = "Access key da conta que sera provisionado o ambiente, variável mantida pelo Terraform Cloud"
}

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
    default = 3
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
    default = [ "AmazonEKSWorkerNodePolicy", "AmazonEKS_CNI_Policy", "AmazonEC2ContainerRegistryReadOnly" ]
}

variable "eks_instance_type" {
    default = "m5.xlarge"
}

variable "workspace" {
    default = "jmeter-eks"
}