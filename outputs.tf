output "vpc_id" {
  description = "ID of my VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block on VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_id_app" {
  description = "Map of private app tier subnet IDs, keyed by AZ's"
  value       = values(module.vpc.private_subnet_id_app)
}

output "public_subnet_id_web" {
  description = "Map of public web tier subnet IDs, keyed by AZ's"
  value       = values(module.vpc.public_subnet_id_web)
}