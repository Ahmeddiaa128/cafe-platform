locals {
  common_tags = merge(
    {
      Terraform   = "true"
      Environment = var.environment
      Project     = "cafe-platform"
    },
    var.tags
  )
}

# ---------- ALB (used in V5) ----------
resource "aws_security_group" "alb" {
  name        = "${var.name}-${var.environment}-alb-sg"
  description = "Allow HTTP/HTTPS from the internet to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # No inline egress: managed by aws_vpc_security_group_egress_rule below
  tags = merge(local.common_tags, { Name = "${var.name}-${var.environment}-alb-sg" })
}

# ---------- Web servers ----------
resource "aws_security_group" "web" {
  name        = "${var.name}-${var.environment}-web-sg"
  description = "Web servers: HTTP from ALB, SSH from admin IPs"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  dynamic "ingress" { # Version 2 & 3: direct HTTP, before the ALB exists
    for_each = length(var.web_http_cidrs) > 0 ? [1] : []
    content {
      description = "HTTP direct (no ALB)"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.web_http_cidrs
    }
  }

  tags = merge(local.common_tags, { Name = "${var.name}-${var.environment}-web-sg" })
}

# ---------- Database ----------
resource "aws_security_group" "db" {
  name        = "${var.name}-${var.environment}-db-sg"
  description = "Database: only from web servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "DB from web SG"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  tags = merge(local.common_tags, { Name = "${var.name}-${var.environment}-db-sg" })
}

# =====================================================
# Egress rules (least privilege)
# =====================================================

# ----- web-sg -----
resource "aws_vpc_security_group_egress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  description       = "HTTPS: SSM API and file downloads"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP: dnf package repositories"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "web_to_db" {
  security_group_id            = aws_security_group.web.id
  description                  = "MySQL/MariaDB to the database SG"
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.db.id
}

# ----- alb-sg (V5) -----
resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id            = aws_security_group.alb.id
  description                  = "HTTP to web servers"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.web.id
}

# ----- db-sg: no egress rules (RDS does not initiate connections) -----