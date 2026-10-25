output "asg_name" {
  value = aws_autoscaling_group.web.name
}

output "ami_id" {
  value = local.ami_id
}