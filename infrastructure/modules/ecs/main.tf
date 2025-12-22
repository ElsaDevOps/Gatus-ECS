terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


resource "aws_ecs_cluster" "this" {
  name = "gatus-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecs_service" "gatus" {
  name            = "gatus"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.gatus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "my-gatus"
    container_port   = 8080
  }
}

resource "aws_ecs_task_definition" "gatus" {
  family                   = "gatus"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name                   = "my-gatus"
      image                  = "${var.ecr_url}:${var.image_tag}"
      essential              = true
      readonlyRootFilesystem = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }

  ])


}

resource "aws_iam_role" "ecs_task_execution" {
  name = "Execute-role"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = "sts:AssumeRole"
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          }
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
