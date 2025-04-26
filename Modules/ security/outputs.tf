output "alb_sg_id" {
  description = "ID of the Application Load Balancer Security Group"
  value       = aws_security_group.alb_sg.id
}

output "web_sg_id" {
  description = "ID of the Web/App Server Security Group"
  value       = aws_security_group.web_sg.id
}

output "db_sg_id" {
  description = "ID of the Database Security Group"
  value       = aws_security_group.db_sg.id
}
