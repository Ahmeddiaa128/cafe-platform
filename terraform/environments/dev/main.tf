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
  web_http_cidrs    = ["0.0.0.0/0"] # V2: no ALB yet
}



# Version 1
#module "static_site" {
#  source = "../../modules/s3-static-site"

#  name        = "cafe"
#  environment = "dev"
#  site_path   = "${path.root}/../../../app/static-site"
#}



# Version 2
#module "ssm_parameters" {
#  source      = "../../modules/ssm-parameters"
#  environment = "dev"
#}

module "compute" {
  source = "../../modules/compute"

  name               = "cafe"
  environment        = "dev"
  subnet_ids         = [module.network.public_subnet_ids[0]] # V2 & V3: one instance
  security_group_ids = [module.security_groups.web_sg_id]
}




# Version 3
resource "random_password" "db" {
  length  = 20
  special = false
}

module "ssm_parameters" {
  source      = "../../modules/ssm-parameters"
  environment = "dev"
  db_host     = module.database.address
  db_password = random_password.db.result
}

module "database" {
  source = "../../modules/database"

  name               = "cafe"
  environment        = "dev"
  subnet_ids         = module.network.private_subnet_ids
  security_group_ids = [module.security_groups.db_sg_id]
  password           = random_password.db.result
}


#output "website_url" {
#  value = "http://${module.static_site.website_endpoint}"
#}

output "web_public_ip" {
  value = module.compute.public_ips[0]
}

output "ssm_parameter_prefix" {
  value = module.ssm_parameters.parameter_prefix
}