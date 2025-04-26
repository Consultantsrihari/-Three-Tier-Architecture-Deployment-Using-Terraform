# terraform.tfvars.example
# Copy this file to terraform.tfvars and fill in the values.
# DO NOT commit terraform.tfvars to version control if it contains secrets.

# --- Required Variables ---

db_username = "<YOUR_RDS_USERNAME>"       # Replace with your desired DB master username
db_password = "<YOUR_SECURE_RDS_PASSWORD>" # Replace with a strong password

# --- AWS Configuration (Optional Overrides) ---

# aws_region = "us-east-1"
# project_name = "my-prod-app"

# --- Network Configuration (Optional Overrides) ---

# vpc_cidr             = "10.1.0.0/16"
# public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
# private_subnet_cidrs = ["10.1.101.0/24", "10.1.102.0/24"]

# --- Compute Configuration (Optional Overrides) ---

# instance_type        = "t3.small"
# asg_min_size         = 2
# asg_max_size         = 10
# asg_desired_capacity = 3
# ec2_key_pair_name    = "your-existing-key-pair-name" # Set if using SSH key pairs

# --- Database Configuration (Optional Overrides) ---

# db_instance_class    = "db.t3.small"
# db_engine            = "postgres"
# db_engine_version    = "14" # Ensure this matches the chosen engine
# db_name              = "my_application_db"
# db_allocated_storage = 50
# db_multi_az          = true

# --- Security Configuration (Optional Overrides) ---

# allow_ssh_cidrs = ["YOUR_HOME_IP/32", "YOUR_OFFICE_IP/32"] # Replace with actual IPs if enabling SSH
