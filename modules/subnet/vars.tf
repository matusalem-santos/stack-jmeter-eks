variable "subnet_name" {
    default = "private"
}

variable "subnet_count" {
    default = 1
}

variable "subnet_cidr_block" {
    default = 10
}

variable "subnet_depens_on" {
    default = null
}

variable "vpc_id" {}

variable "vpc_cidr_block" {}

variable "public_ip" {
    type = bool
    default = false
}

variable "env" {
    default = "stage"
}

variable "workspace" {}