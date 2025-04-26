variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS instance"
  type        = list(string)
}

variable "db_sg_id" {
  description = "ID of the Security Group to attach to the RDS instance"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_engine" {
  description = "RDS database engine ('mysql' or 'postgres')"
  type        = string
}

variable "db_engine_version" {
  description = "RDS database engine version"
  type        = string
}

variable "db_name" {
  description = "Name for the RDS database"
  type        = string
}

variable "db_username" {
  description = "Username for the RDS database master user"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the RDS database master user"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS instance in GB"
  type        = number
}

variable "db_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
}

# Optional variables
variable "db_backup_retention_period" {
  description = "Days to retain backups"
  type        = number
  default     = 7 # Default to 7 days
}

variable "db_skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before deletion. Set to false for production."
  type        = bool
  default     = true # Easier cleanup for dev/test
}

variable "db_deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. Set to true for production."
  type        = bool
  default     = false # Easier cleanup for dev/test
}
