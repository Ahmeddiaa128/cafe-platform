terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "../../modules/network"

  name        = "cafe"
  environment = "dev"

  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway = false
}

module "security_groups" {
  source = "../../modules/security-groups"

  name        = "cafe"
  environment = "dev"
  vpc_id      = module.network.vpc_id

  ssh_allowed_cidrs = var.ssh_allowed_cidrs
}