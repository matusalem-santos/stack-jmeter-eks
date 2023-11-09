

variable "env" {
    default = "dev"
}

variable "aws_region"{
    default = "us-east-2"
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
    default = [ "service-role/AmazonEBSCSIDriverPolicy","AmazonEKSWorkerNodePolicy", "AmazonEKS_CNI_Policy", "AmazonEC2ContainerRegistryReadOnly", "AmazonSSMManagedInstanceCore"]
}

variable "eks_instance_type" {
    default = "m5.xlarge"
}

variable "workspace" {
    default = "jmeter-eks"
}

variable "cluster_addons" {
    description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
    type        = any
    default     = {
        aws-ebs-csi-driver = {
            resolve_conflicts_on_create = "OVERWRITE"
            addon_version     = "v1.24.1-eksbuild.1"            
        }
    }
}
