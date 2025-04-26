variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where instances will be launched"
  type        = list(string)
}

variable "web_sg_id" {
  description = "ID of the Security Group for the web/app instances"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB Target Group to attach instances to"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
}

variable "ec2_key_pair_name" {
  description = "Name of the EC2 Key Pair (set to empty string '' to disable)"
  type        = string
}

variable "user_data_script" {
  description = "User data script content"
  type        = string
  default     = null # Or provide a default script content
}

variable "user_data_vars" {
  description = "Map of variables to pass to the user data script template (if using templatefile)"
  type        = map(string)
  default     = {}
}

# variable "iam_instance_profile_name" {
#   description = "Name of the IAM instance profile to associate with EC2 instances (optional)"
#   type        = string
#   default     = null
# }
