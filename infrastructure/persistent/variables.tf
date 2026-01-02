variable "domain_name" {
  description = "the domain name"
  type        = string
  default     = "elsagatus.com"
}

variable "alert_email" {
  description = "Email for CloudWatch alerts"
  type        = string
  sensitive   = true
}
