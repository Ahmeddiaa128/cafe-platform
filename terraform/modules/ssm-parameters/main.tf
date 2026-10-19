locals {
  prefix = "/cafe"
  tags = {
    Environment = var.environment
    Project     = "cafe-platform"
    Terraform   = "true"
  }

  plain_params = {
    showServerInfo = var.show_server_info
    timeZone       = var.time_zone
    currency       = var.currency
    dbUrl          = var.db_host
    dbName         = var.db_name
    dbUser         = var.db_user
  }
}

resource "random_password" "db" {
  length  = 20
  special = false
}

resource "random_password" "db_root" {
  length  = 20
  special = false
}

resource "aws_ssm_parameter" "plain" {
  for_each = local.plain_params

  name  = "${local.prefix}/${each.key}"
  type  = "String"
  value = each.value
  tags  = local.tags
}

resource "aws_ssm_parameter" "db_password" {
  name  = "${local.prefix}/dbPassword"
  type  = "SecureString"
  value = random_password.db.result
  tags  = local.tags
}

resource "aws_ssm_parameter" "db_root_password" {
  name  = "${local.prefix}/dbRootPassword"
  type  = "SecureString"
  value = random_password.db_root.result
  tags  = local.tags
}