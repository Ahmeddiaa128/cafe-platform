variable "environment" {
  type = string
}

variable "db_name" {
  type    = string
  default = "cafe_db"
}

variable "db_user" {
  type    = string
  default = "admin"
}

variable "db_host" {
  type    = string
  default = "localhost"
}

variable "time_zone" {
  type    = string
  default = "America/New_York"
}

variable "currency" {
  type    = string
  default = "$"
}

variable "show_server_info" {
  type    = string
  default = "false"
}