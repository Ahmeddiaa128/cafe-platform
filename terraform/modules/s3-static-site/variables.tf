variable "name" {
  description = "Name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "index_document" {
  type    = string
  default = "index.html"
}


variable "site_path" {
  description = "Local folder containing the site files"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}