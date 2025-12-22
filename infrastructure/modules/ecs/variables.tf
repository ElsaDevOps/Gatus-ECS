variable "ecr_url" {
  type        = string
  description = "The URL of the ECR repository"
}

variable "image_tag" {
  type        = string
  description = "The SHA of the image"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The ID where the tasks will be created"
}

variable "target_group_arn" {
  type        = string
  description = "The target group ARN"
}

variable "ecs_security_group_id" {
  type        = string
  description = "The security group ID for ECS"
}
