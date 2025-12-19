resource "aws_route53_record" "tm" {
  zone_id         = data.terraform_remote_state.persistent.outputs.hosted_zone_id
  name            = "tm.${var.domain_name}"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "root" {
  zone_id         = data.terraform_remote_state.persistent.outputs.hosted_zone_id
  name            = var.domain_name
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
