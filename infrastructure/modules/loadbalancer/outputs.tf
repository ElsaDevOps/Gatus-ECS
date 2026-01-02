output "alb_dns_name" {
  value = aws_lb.gs_alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.gs_alb.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.gs_alb_tg.arn
}

output "alb_arn" {
  value = aws_lb.gs_alb.arn
}

output "alb_arn_suffix" {
  value = aws_lb.gs_alb.arn_suffix

}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.gs_alb_tg.arn_suffix

}
