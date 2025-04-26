output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "The port on which the DB instance is listening"
  value       = aws_db_instance.main.port
}

output "rds_instance_id" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.main.id
}

output "rds_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "rds_db_name" {
  description = "The database name"
  value       = aws_db_instance.main.db_name
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}
