variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

variable "allow_ssh_cidrs" {
  description = "List of CIDR blocks allowed for SSH access to EC2 instances"
  type        = list(string)
  default     = []
}

variable "db_engine" {
  description = "Database engine ('mysql' or 'postgres') to determine port"
  type        = string
}
