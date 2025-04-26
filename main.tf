# Selects the number of AZs to use based on the number of public subnets defined
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))
}

module "network" {
  source = "./modules/network"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = local.azs
  aws_region           = var.aws_region # Pass region if needed by module (e.g., for NAT EIP domain)
}

module "security" {
  source = "./modules/security"

  project_name    = var.project_name
  vpc_id          = module.network.vpc_id
  allow_ssh_cidrs = var.allow_ssh_cidr
  db_engine       = var.db_engine # Pass DB engine to determine default port
}

module "load_balancer" {
  source = "./modules/load_balancer"

  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}

module "compute" {
  source = "./modules/compute"

  project_name         = var.project_name
  vpc_id               = module.network.vpc_id # Needed for user data templating if passing VPC specific info
  public_subnet_ids    = module.network.public_subnet_ids
  web_sg_id            = module.security.web_sg_id
  alb_target_group_arn = module.load_balancer.alb_target_group_arn
  ami_id               = data.aws_ami.amazon_linux_2.id
  instance_type        = var.instance_type
  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity
  ec2_key_pair_name    = var.ec2_key_pair_name
  user_data_script     = file("${path.module}/user_data/install_web.sh")

  # Example of passing data to user_data if needed (use templatefile in module)
  # user_data_vars = {
  #   db_endpoint = module.database.rds_endpoint
  #   db_user     = var.db_username
  #   # Avoid passing passwords this way in production! Use Secrets Manager + IAM Role.
  # }

  depends_on = [module.load_balancer] # Ensure LB/TG exists before ASG tries to attach
}

module "database" {
  source = "./modules/database"

  project_name         = var.project_name
  private_subnet_ids   = module.network.private_subnet_ids
  db_sg_id             = module.security.db_sg_id
  db_instance_class    = var.db_instance_class
  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_allocated_storage = var.db_allocated_storage
  db_multi_az          = var.db_multi_az
}
