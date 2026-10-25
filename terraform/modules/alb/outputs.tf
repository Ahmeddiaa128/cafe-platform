output "dns_name" {
  value = aws_lb.cafe.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.web.arn
}