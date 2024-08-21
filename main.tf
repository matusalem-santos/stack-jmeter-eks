terraform {
  # Versão do terraform definida no Terraform Cloud
  required_version = "~> 1.3.4"
  # Informações do Projeto no Terraform Cloud
  backend "local" {
    path = "terraform.tfstate"
  }
}
provider "aws" {
  region = var.aws_region
}



