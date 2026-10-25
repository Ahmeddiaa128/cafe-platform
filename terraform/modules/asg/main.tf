data "aws_ami" "web" {
  count       = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["cafe-web-*"]
  }

  filter {
    name   = "tag:Project"
    values = ["cafe-platform"]
  }
}

locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.web[0].id
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.name}-${var.environment}-web-"
  image_id      = local.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_group_ids
  }

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.name}-${var.environment}-web"
      Environment = var.environment
      Project     = "cafe-platform"
      Role        = "web"
      Terraform   = "true"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "${var.name}-${var.environment}-asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = "EC2"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-${var.environment}-web"
    propagate_at_launch = true
  }
}