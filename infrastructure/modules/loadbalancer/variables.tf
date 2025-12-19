variable "project_name" {
  description = "Name of the project, used for tagging and naming resources"
  type        = string
  default     = "Gatus"
}

variable "domain_name" {
  description = "the domain name"
  type        = string
}

variable "gs_alb_sg_id" {
  description = "the ID of the ALB sg"
  type        = string

}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string

}

variable "public_subnet_id_web" {
  description = "The Id of the public subnet"
  type        = map(string)

}

variable "certificate_arn" {
  description = "The ARN of the acm cert"
  type        = string

}
