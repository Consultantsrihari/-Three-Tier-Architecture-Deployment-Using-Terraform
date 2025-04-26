output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.load_balancer.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer (for Route53 Alias records)"
  value       = module.load_balancer.alb_zone_id
}

output "rds_endpoint" {
  description = "Endpoint address of the RDS database instance"
  value       = module.database.rds_endpoint
  sensitive   = true # Endpoint might be considered sensitive
}

output "rds_port" {
  description = "Port of the RDS database instance"
  value       = module.database.rds_port
}

output "rds_db_name" {
  description = "Name of the database created in RDS"
  value       = module.database.rds_db_name
}

output "web_sg_id" {
  description = "ID of the Web/App Server Security Group"
  value       = module.security.web_sg_id
}

output "db_sg_id" {
  description = "ID of the Database Security Group"
  value       = module.security.db_sg_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.network.private_subnet_ids
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}
