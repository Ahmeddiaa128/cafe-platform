locals {
  tags = {
    Environment = var.environment
    Project     = "cafe-platform"
    Terraform   = "true"
  }
}

resource "aws_lb" "cafe" {
  name               = "${var.name}-${var.environment}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids

  tags = local.tags
}

resource "aws_lb_target_group" "web" {
  name     = "${var.name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = local.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.cafe.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}