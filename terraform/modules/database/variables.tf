variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_ids" {
  description = "Private subnets in at least 2 AZs"
  type        = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "db_name" {
  type    = string
  default = "cafe_db"
}

variable "username" {
  type    = string
  default = "admin"
}

variable "password" {
  type      = string
  sensitive = true
}

variable "engine_version" {
  type    = string
  default = "10.11"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  description = "Not supported in the AWS Academy sandbox"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}