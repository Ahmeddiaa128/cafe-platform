variable "name" {
  description = "Name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from the network module"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string)
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "tags" {
  description = "Extra tags"
  type        = map(string)
  default     = {}
}