terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


resource "aws_security_group" "gs_app_sg" {
  name        = "Gatus-app-sg"
  description = "security group for Gatus Fargate tasks"
  vpc_id      = var.vpc_id

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }




  tags = {
    Name        = "${var.project_name}-app-sg"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

}





resource "aws_security_group" "gs_alb_sg" {
  name        = "gatus-alb-sg"
  description = "Security group for Gatus ALB"
  vpc_id      = var.vpc_id



  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}



resource "aws_security_group_rule" "allow_alb_to_app" {
  description              = "Allow traffic from ALB to tasks"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.gs_app_sg.id
  source_security_group_id = aws_security_group.gs_alb_sg.id
}

resource "aws_security_group_rule" "allow_http_traffic" {
  description       = "Allow HTTP traffic from internet to ALB"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.gs_alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_https_traffic" {
  description       = "Allow HTTPS traffic from internet to ALB"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.gs_alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
