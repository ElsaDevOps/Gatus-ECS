resource "aws_wafv2_web_acl" "main" {
  # checkov:skip=CKV_AWS_192:Gatus is Go-based, not vulnerable to Log4j (Java)
  # checkov:skip=CKV2_AWS_31:WAF logging not required for portfolio project; metrics enabled via visibility_config
  name        = "gatus-waf"
  description = "WAF for Gatus ALB"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }


  rule {
    name     = "rate-limit"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    action {
      block {}
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "gatus-rate-limit"
    }
  }


  rule {
    name     = "aws-managed-common"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "gatus-aws-common"
    }
  }


  rule {
    name     = "aws-managed-sqli"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "gatus-aws-sqli"
    }
  }

  visibility_config {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
    metric_name                = "gatus-waf"
  }
}

resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = module.loadbalancer.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
