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

module "network" {
  source = "../../modules/network"

  name        = "cafe"
  environment = "prod"

  vpc_cidr        = "10.1.0.0/16"
  public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.11.0/24", "10.1.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "security_groups" {
  source = "../../modules/security-groups"

  name        = "cafe"
  environment = "prod"
  vpc_id      = module.network.vpc_id

  ssh_allowed_cidrs = var.ssh_allowed_cidrs
  web_http_cidrs    = ["0.0.0.0/0"] # V2 & V3: no ALB yet
}



# Version 1
#module "static_site" {
#  source = "../../modules/s3-static-site"

#  name        = "cafe"
#  environment = "prod"
#  site_path   = "${path.root}/../../../app/static-site"
#}

# Version 2
#module "ssm_parameters" {
#  source      = "../../modules/ssm-parameters"
#  environment = "prod"
#}

module "compute" {
  source = "../../modules/compute"

  name               = "cafe"
  environment        = "prod"
  subnet_ids         = [module.network.public_subnet_ids[0]] # V2: one instance
  security_group_ids = [module.security_groups.web_sg_id]
}

# Version 3
resource "random_password" "db" {
  length  = 20
  special = false
}

module "ssm_parameters" {
  source      = "../../modules/ssm-parameters"
  environment = "prod"
  db_host     = module.database.address
  db_password = random_password.db.result
}

module "database" {
  source = "../../modules/database"

  name               = "cafe"
  environment        = "prod"
  subnet_ids         = module.network.private_subnet_ids
  security_group_ids = [module.security_groups.db_sg_id]
  password           = random_password.db.result
}

# Version 4
module "nacl" {
  source = "../../modules/nacl"

  name        = "cafe"
  environment = "prod"
  vpc_id      = module.network.vpc_id

  public_subnet_ids    = module.network.public_subnet_ids
  private_subnet_ids   = module.network.private_subnet_ids
  public_subnet_cidrs  = module.network.public_subnet_cidrs
  private_subnet_cidrs = module.network.private_subnet_cidrs

  ssh_allowed_cidrs = var.ssh_allowed_cidrs
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