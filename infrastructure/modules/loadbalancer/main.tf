terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_lb" "gs_alb" {
  name                       = "gs-alb-tf"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.gs_alb_sg_id]
  subnets                    = values(var.public_subnet_id_web)
  idle_timeout               = 300
  drop_invalid_header_fields = true # Drop invalid headers to prevent HTTP desync attacks


  tags = {
    Name        = "${var.project_name}-alb"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_target_group" "gs_alb_tg" {
  name                 = "tf-gs-lb-tg"
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 300



  health_check {
    enabled             = true
    interval            = 30
    timeout             = 5
    matcher             = "200,302"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
  }


}

# HTTP listener redirects to HTTPS - no unencrypted traffic
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.gs_alb.arn
  port              = "80"
  protocol          = "HTTP"




  default_action {
    type = "redirect"


    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.gs_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gs_alb_tg.arn
  }
}

# Redirect non-tm to tm (applied only to root domain)
resource "aws_lb_listener_rule" "redirect_root_to_tm" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  action {
    type = "redirect"

    redirect {
      host        = var.domain_name
      path        = "/#{path}"
      query       = "#{query}"
      port        = "#{port}"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [var.domain_name]
    }
  }
}
