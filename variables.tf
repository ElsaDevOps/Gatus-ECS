variable "cidr_blockvpc" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}
variable "cidr_private_subnet_app" {
  type        = list(string)
  description = "CIDR blocks for private subnets on the app tier"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}


variable "cidr_public_subnet_web" {
  type        = list(string)
  description = "CIDR blocks for public subnets on the web tier"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to deploy to"
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "project_name" {
  description = "Name of the project, used for tagging and naming resources"
  type        = string
  default     = "gatus"
}

