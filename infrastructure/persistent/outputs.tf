output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.main.id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.my_gatus.repository_url
}
