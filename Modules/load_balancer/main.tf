resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids # Deploy ALB across specified public subnets

  enable_deletion_protection = false # Set to true for production environments

  tags = merge(
    { Name = "${var.project_name}-alb" },
    { Project = var.project_name, Terraform = "true" }
  )
}

resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-tg"
  port        = var.instance_port
  protocol    = "HTTP" # Protocol to instances (ALB talks HTTP to instances here)
  vpc_id      = var.vpc_id
  target_type = "instance" # Could be 'ip' for ECS/Fargate

  health_check {
    enabled             = true
    interval            = 30 # Seconds between health checks
    path                = "/" # Path to check on the instance
    port                = "traffic-port" # Use the instance port defined above
    protocol            = "HTTP"
    timeout             = 5  # Seconds to wait for a response
    healthy_threshold   = 3  # Consecutive successes to be considered healthy
    unhealthy_threshold = 3  # Consecutive failures to be considered unhealthy
    matcher             = "200" # Expected HTTP status code for healthy
  }

  tags = merge(
    { Name = "${var.project_name}-tg" },
    { Project = var.project_name, Terraform = "true" }
  )

  # Important for smooth ASG updates
  lifecycle {
    create_before_destroy = true
  }
}

# Listener for HTTP traffic on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Default action: forward traffic to the target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# --- Optional: HTTPS Listener ---
# variable "acm_certificate_arn" {
#   description = "ARN of the ACM certificate for HTTPS listener (set to null or empty string to disable HTTPS)"
#   type        = string
#   default     = ""
# }
#
# resource "aws_lb_listener" "https" {
#   count = var.acm_certificate_arn != "" ? 1 : 0 # Only create if ARN is provided
#
#   load_balancer_arn = aws_lb.main.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08" # Choose an appropriate security policy
#   certificate_arn   = var.acm_certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.main.arn
#   }
# }

# --- Optional: Redirect HTTP to HTTPS ---
# resource "aws_lb_listener_rule" "http_redirect" {
#   count = var.acm_certificate_arn != "" ? 1 : 0 # Only create if HTTPS listener exists
#
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 1 # Lowest priority rule
#
#   action {
#     type = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301" # Permanent redirect
#     }
#   }
#
#   condition {
#     path_pattern {
#       values = ["/*"] # Apply to all paths
#     }
#   }
# }
