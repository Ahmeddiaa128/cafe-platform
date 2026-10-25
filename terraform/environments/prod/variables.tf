variable "ssh_allowed_cidrs" {
  description = "Your public IP in CIDR form"
  type        = list(string)
}

variable "web_ami_id" {
  description = "AMI built from the configured builder instance (empty = look up newest cafe-web-*)"
  type        = string
  default     = ""
}