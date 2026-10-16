variable "name" {
  description = "Name prefix for network resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s) for private subnets"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags for all resources"
  type        = map(string)
  default     = {}
}