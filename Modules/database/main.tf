# RDS Subnet Group (tells RDS which subnets it can use)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids # Place RDS in private subnets

  tags = merge(
    { Name = "${var.project_name}-db-subnet-group" },
    { Project = var.project_name, Terraform = "true" }
  )
}

# Determine correct parameter group based on engine/version (simplified)
# Note: For precise control, use aws_db_parameter_group resource
locals {
  # This is a simplification; precise default group names can vary slightly.
  # Check AWS console/docs for exact default names for your engine/version.
  mysql_family    = replace(var.db_engine_version, ".", "") # e.g., "8.0" -> "80"
  postgres_family = replace(var.db_engine_version, ".", "") # e.g., "14.1" -> "141" - might need adjustment

  # Crude guess at default parameter group name - VERIFY this in your AWS account/docs
  default_parameter_group_name = var.db_engine == "mysql" ? "default.${var.db_engine}${element(split(".", var.db_engine_version), 0)}.${element(split(".", var.db_engine_version), 1)}" : "default.${var.db_engine}${element(split(".", var.db_engine_version), 0)}"
  # Example: default.mysql8.0, default.postgres14
}


# RDS Database Instance
resource "aws_db_instance" "main" {
  identifier           = "${var.project_name}-rds" # Must be unique within AWS account/region
  allocated_storage    = var.db_allocated_storage
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  # parameter_group_name = local.default_parameter_group_name # Use default PG for simplicity, or create/specify custom one
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  multi_az             = var.db_multi_az
  publicly_accessible  = false                     # Keep database private
  storage_type         = "gp2"                     # General Purpose SSD (consider gp3 or io1 for production)

  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  final_snapshot_identifier = var.db_skip_final_snapshot ? null : "${var.project_name}-rds-final-snapshot-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  deletion_protection     = var.db_deletion_protection

  # Enable Storage Encryption (Recommended)
  storage_encrypted = true
  # kms_key_id = "arn:aws:kms:..." # Optional: Specify a custom KMS key

  # Enable Performance Insights (Optional, incurs cost)
  # performance_insights_enabled = true
  # performance_insights_retention_period = 7 # Default 7 days

  # Enable Enhanced Monitoring (Optional, incurs cost)
  # monitoring_interval = 60 # e.g., 60 seconds
  # monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn # Requires creating an IAM role

  tags = merge(
    { Name = "${var.project_name}-rds" },
    { Project = var.project_name, Terraform = "true", Tier = "Database" }
  )

  # Allow Terraform to replace the instance if certain parameters change (e.g. identifier)
  # Note: This will cause downtime and data loss if not handled carefully (e.g., restoring from snapshot)
  # lifecycle {
  #   create_before_destroy = true
  # }
}
