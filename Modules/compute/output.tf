output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.main.id
}

output "launch_template_latest_version" {
    description = "Latest version number of the Launch Template"
    value = aws_launch_template.main.latest_version
}
