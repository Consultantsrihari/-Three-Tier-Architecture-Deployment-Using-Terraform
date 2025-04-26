output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the ALB (for Route53 Alias records)"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_target_group_arn" {
  description = "ARN of the default Target Group"
  value       = aws_lb_target_group.main.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP Listener"
  value       = aws_lb_listener.http.arn
}

# output "https_listener_arn" {
#   description = "ARN of the HTTPS Listener (if created)"
#   value       = try(aws_lb_listener.https[0].arn, null)
# }
