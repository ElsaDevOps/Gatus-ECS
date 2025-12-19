output "gs_app_sg_id" {
  value = aws_security_group.gs_app_sg.id
}

output "gs_alb_sg_id" {
  value = aws_security_group.gs_alb_sg.id
}
