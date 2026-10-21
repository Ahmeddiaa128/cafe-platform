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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

    dynamic "ingress" {                                    #Version 2&3
    for_each = length(var.web_http_cidrs) > 0 ? [1] : []
    content {
      description = "HTTP direct (no ALB)"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.web_http_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name}-${var.environment}-db-sg" })
}