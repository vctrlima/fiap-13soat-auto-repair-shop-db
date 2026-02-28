# =============================================================================
# Database Infrastructure - Outputs
# Consumed by k8s-infrastructure and application for DB connection
# =============================================================================

output "database_host" {
  description = "RDS PostgreSQL endpoint hostname"
  value       = module.database.address
}

output "database_port" {
  description = "RDS PostgreSQL port"
  value       = module.database.port
}

output "database_name" {
  description = "Database name"
  value       = module.database.db_name
}

output "database_endpoint" {
  description = "Full RDS endpoint (host:port)"
  value       = module.database.endpoint
}

output "database_arn" {
  description = "RDS instance ARN"
  value       = module.database.arn
}

output "database_security_group_id" {
  description = "Security group ID for the RDS instance"
  value       = module.database.security_group_id
}
