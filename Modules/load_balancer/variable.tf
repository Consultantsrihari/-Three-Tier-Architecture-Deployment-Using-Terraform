variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ID of the Security Group to attach to the ALB"
  type        = string
}

variable "instance_port" {
  description = "Port the instances are listening on"
  type        = number
  default     = 80
}
