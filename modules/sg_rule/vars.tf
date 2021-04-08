variable "sg_rule_type" {
    default = "ingress"
}

variable "sg_port_from" {
    default = -1
}

variable "sg_port_to" {
    default = -1
}

variable "sg_protocol" {
    default = "tcp"
}

variable "sg_id" {}

variable "sg_rule_count" {
    default = 1
}

variable "ss_group_id" {
    default = null
}

variable "sg_rule_depens_on" {
    default = null
}

variable "cidr" {
    default = null
}