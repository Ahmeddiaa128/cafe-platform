terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
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

module "static_site" {
  source = "../../modules/s3-static-site"

  name        = "cafe"
  environment = "dev"
  site_path   = "${path.root}/../../../app/static-site"
}

output "website_url" {
  value = "http://${module.static_site.website_endpoint}"
}