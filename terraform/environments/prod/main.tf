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
}