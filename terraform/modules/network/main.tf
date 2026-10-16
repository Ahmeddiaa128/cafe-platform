module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = "${var.name}-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Terraform   = "true"
      Environment = var.environment
      Project     = "cafe-platform"
    },
    var.tags
  )
}




