variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_ids" {
  description = "Public subnets, one per AZ"
  type        = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arns" {
  type = list(string)
}

variable "ami_id" {
  description = "The newest cafe-web-* AMI owned by this account is used."
  type        = string
  default     = ""
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = "vockey"
}

variable "instance_profile_name" {
  type    = string
  default = "LabInstanceProfile"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_capacity" {
  type    = number
  default = 2
}