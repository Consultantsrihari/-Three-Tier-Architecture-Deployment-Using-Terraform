#------------------------------------------------------------------------------
# General AWS Configuration
#------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "A name prefix used for tagging and naming resources"
  type        = string
  default     = "webapp-3tier"
}

#------------------------------------------------------------------------------
# Network Configuration
#------------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets. Must match the number of AZs desired."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"] # Defaulting to 2 AZs
  # Ensure this matches the number of AZs you intend to use (see local.azs)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets. Must match the number of AZs desired."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"] # Defaulting to 2 AZs
}

#------------------------------------------------------------------------------
# Compute Configuration (Web/App Tier)
#------------------------------------------------------------------------------
variable "instance_type" {
  description = "EC2 instance type for the web/app servers"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 5
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "ec2_key_pair_name" {
  description = "Name of the EC2 Key Pair to associate with instances (optional, leave empty '' if not using key pairs for SSH - e.g., using SSM Session Manager). If set, ensure the key pair exists in the target region."
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Database Configuration (DB Tier)
#------------------------------------------------------------------------------
variable "db_instance_class" {
  description = "RDS instance class (e.g., db.t3.micro, db.m5.large)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine" {
  description = "RDS database engine ('mysql' or 'postgres')"
  type        = string
  default     = "mysql"
  validation {
    condition     = contains(["mysql", "postgres"], var.db_engine)
    error_message = "Allowed values for db_engine are \"mysql\" or \"postgres\"."
  }
}

variable "db_engine_version" {
  description = "RDS database engine version (e.g., '8.0' for MySQL, '14' for PostgreSQL). Check AWS docs for supported versions."
  type        = string
  default     = "8.0" # Adjust based on chosen engine and AWS supported versions
}

variable "db_name" {
  description = "The name of the database to create within the RDS instance"
  type        = string
  default     = "webappdb"
}

variable "db_username" {
  description = "Master username for the RDS database. Store securely (e.g., terraform.tfvars, Secrets Manager)."
  type        = string
  sensitive   = true
  # No default - must be provided
}

variable "db_password" {
  description = "Master password for the RDS database. Store securely."
  type        = string
  sensitive   = true
  # No default - must be provided
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS instance in gigabytes (GB)"
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------
variable "allow_ssh_cidr" {
  description = "List of CIDR blocks allowed for SSH access to EC2 instances (e.g., your home/office IP). Use [''] or [] to disable direct SSH access (recommended if using SSM)."
  type        = list(string)
  default     = [] # Default to no SSH access for security
  # Example: default = ["YOUR_IP_ADDRESS/32"]
}
