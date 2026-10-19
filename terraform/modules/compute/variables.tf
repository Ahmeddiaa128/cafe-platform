variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_ids" {
  description = "One subnet per instance (V2: one public subnet)"
  type        = list(string)
}

variable "security_group_ids" {
  type = list(string)
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

variable "root_volume_size" {
  type    = number
  default = 8
}

variable "tags" {
  type    = map(string)
  default = {}
}