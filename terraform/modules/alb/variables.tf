variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Public subnets in at least 2 AZs"
  type        = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "health_check_path" {
  type    = string
  default = "/cafe/"
}