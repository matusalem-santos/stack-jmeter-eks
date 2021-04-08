variable "sg_name" {
    default = "private"
}

variable "sg_vpc_id" {}

variable "sg_depens_on" {}

variable "env" {
    default = "stage"
}

variable "workspace" {}