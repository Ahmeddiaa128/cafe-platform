locals {
  tags = merge(
    {
      Environment = var.environment
      Project     = "cafe-platform"
      Terraform   = "true"
    },
    var.tags
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-${var.environment}-db-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(local.tags, { Name = "${var.name}-${var.environment}-db-subnets" })
}

resource "aws_db_instance" "db" {
  identifier = "${var.name}-${var.environment}-db"

  engine         = "mariadb"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false
  multi_az               = var.multi_az

  monitoring_interval     = 0 # enhanced monitoring is not supported
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  tags = merge(local.tags, { Name = "${var.name}-${var.environment}-db" })
}