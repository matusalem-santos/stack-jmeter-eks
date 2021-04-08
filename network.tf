# VPC
module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = var.vpc_cidr
    workspace = var.workspace
}

# Internet Gateway
module "igw" {
  source = "./modules/internet_gw"
  env = var.env
  igw_vpc_id = module.vpc.id
  workspace = var.workspace
}

# Public Subnet
module "public_subnet" {
    source = "./modules/subnet"  
    env = var.env
    subnet_count = var.subnet_count
    vpc_id = module.vpc.id
    vpc_cidr_block = module.vpc.cidr_block
    subnet_name = "public"
    public_ip = true
    subnet_cidr_block = 10
    workspace = var.workspace

    subnet_depens_on = module.vpc
}

# Public
module "public_route_table" {
  source = "./modules/route_table"
  route_vpc_id = module.vpc.id
  route_table_name = var.public_rtb_name
  workspace = var.workspace
  rtb_depens_on = module.vpc
}

module "public_route" {
  source = "./modules/route"
  rtb_id = module.public_route_table.id
  rtb_destination = var.internet_cidr
  rtb_gateway = module.igw.id
  workspace = var.workspace
  
  route_depends_on = [ module.public_route_table, module.igw ]
}

module "public_rtb_assoc" {
  source = "./modules/route_association"
  sub_id = module.public_subnet.id
  rtb_id = module.public_route_table.id
  assoc_depends_on = module.public_route_table
}