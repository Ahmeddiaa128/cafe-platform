variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "ssh_allowed_cidrs" {
  description = "Admin CIDRs allowed to SSH to the public subnets"
  type        = list(string)
}

variable "db_port" {
  type    = number
  default = 3306
}

variable "tags" {
  type    = map(string)
  default = {}
}