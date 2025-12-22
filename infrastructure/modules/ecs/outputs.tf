output "cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "The ecs cluster name"
}

output "service_name" {
  value       = aws_ecs_service.gatus.name
  description = "the ecs service name"
}
