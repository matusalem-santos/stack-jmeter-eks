terraform {
  # Versão do terraform definida no Terraform Cloud
  required_version = "~> 0.14.3"
  # Informações do Projeto no Terraform Cloud
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "monit"

    workspaces {
      name = "jmeter-eks-terraform"
    }
  }
}
provider "aws" {
  region = var.aws_region
}



