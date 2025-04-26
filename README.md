# Three-Tier-Architecture-Deployment-Using-Terraform

# Project Goal
Deploy a scalable, secure, and highly available web application infrastructure on AWS using Terraform, following the 3-tier architecture pattern.
# Tiers:
Web Tier (Public Subnets): Application Load Balancer (ALB) receiving internet traffic and EC2 instances (managed by an Auto Scaling Group) running a simple web server.
Application Tier (Could be combined with Web Tier in this example): The EC2 instances also represent the application logic tier for simplicity. In more complex setups, this might be a separate set of instances/services in private subnets.
Database Tier (Private Subnets): RDS MySQL/PostgreSQL instance, inaccessible directly from the internet.

Prerequisites

 AWS Account: An active AWS account with sufficient permissions to create the resources (VPC, EC2, RDS, ALB, IAM etc.).
 AWS CLI: Installed and configured with credentials (aws configure).
 Terraform: Installed (version 1.0 or later recommended).
 Git & GitHub Account (Optional but Recommended): For version control.
 Key Pair (Optional but Recommended for direct SSH): An EC2 Key Pair created in your target AWS region if you want SSH access to instances. We'll make this optional in the variables. Using AWS Systems Manager 
 Session Manager is often preferred over direct SSH.
