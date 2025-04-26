# Security Group for ALB (allows HTTP/HTTPS from anywhere)
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP/HTTPS inbound traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    { Name = "${var.project_name}-alb-sg" },
    { Project = var.project_name, Terraform = "true" }
  )
}

# Security Group for Web/App Servers
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP from ALB and optionally SSH from specified IPs"
  vpc_id      = var.vpc_id

  # Allow HTTP/HTTPS traffic ONLY from the ALB Security Group
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
   ingress {
    description     = "HTTPS from ALB (if ALB terminates HTTPS and talks HTTP to instance)"
    from_port       = 443 # Usually only needed if instance itself listens on 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }


  # Dynamic block for optional SSH access
  dynamic "ingress" {
    # Only create this block if allow_ssh_cidrs is not empty
    for_each = length(var.allow_ssh_cidrs) > 0 && var.allow_ssh_cidrs[0] != "" ? [1] : []
    content {
      description = "SSH access from allowed IPs"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allow_ssh_cidrs
    }
  }

  # Allow all outbound traffic (for package updates via NAT, talking to RDS, etc.)
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    { Name = "${var.project_name}-web-sg" },
    { Project = var.project_name, Terraform = "true" }
  )
}

# Security Group for RDS Database
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow DB traffic only from Web/App server security group"
  vpc_id      = var.vpc_id

  # Determine DB port based on engine
  locals {
    db_port = var.db_engine == "mysql" ? 3306 : (var.db_engine == "postgres" ? 5432 : 0) # Use 0 or specific port if needed
  }

  # Allow traffic from the Web Security Group on the DB port
  ingress {
    description     = "DB traffic from Web/App SG"
    from_port       = local.db_port
    to_port         = local.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # CRITICAL: Only allow from Web SG
  }

  # Egress - Typically RDS doesn't initiate outbound connections, but allowing all outbound is common practice unless strict rules are required.
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
     ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    { Name = "${var.project_name}-db-sg" },
    { Project = var.project_name, Terraform = "true" }
  )
}
