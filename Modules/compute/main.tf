# If user_data_vars are provided, render the script as a template
# Otherwise, use the raw script content
locals {
  rendered_user_data = var.user_data_script != null ? (
    length(keys(var.user_data_vars)) > 0 ? templatefile(var.user_data_script, var.user_data_vars) : file(var.user_data_script)
  ) : null
  # Base64 encode the final user data
  encoded_user_data = local.rendered_user_data != null ? base64encode(local.rendered_user_data) : null
}


# Launch Template for Auto Scaling Group
resource "aws_launch_template" "main" {
  name_prefix            = "${var.project_name}-lt-"
  description            = "Launch template for ${var.project_name} web/app instances"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.ec2_key_pair_name != "" ? var.ec2_key_pair_name : null
  vpc_security_group_ids = [var.web_sg_id]
  user_data              = local.encoded_user_data # Use base64 encoded data

  # Optional: Associate IAM instance profile if needed
  # iam_instance_profile {
  #   name = var.iam_instance_profile_name
  # }

  # Enforce IMDSv2 for enhanced security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Tag instances and volumes created from this template
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      { Name = "${var.project_name}-instance" },
      { Project = var.project_name, Terraform = "true", Tier = "Web/App" }
    )
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      { Name = "${var.project_name}-volume" },
      { Project = var.project_name, Terraform = "true" }
    )
  }

  # Use lifecycle rule because name_prefix causes replacement on some changes
  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name_prefix          = "${var.project_name}-asg-"
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.asg_desired_capacity
  vpc_zone_identifier  = var.public_subnet_ids # Launch instances across these subnets
  target_group_arns    = [var.alb_target_group_arn] # Register instances with this TG
  health_check_type    = "ELB" # Use ELB health checks in addition to EC2 checks
  health_check_grace_period = 300 # Seconds to allow instance to start before checking health

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest" # Always use the latest version of the launch template
  }

  # Tags applied to the ASG itself and propagated to instances
  dynamic "tag" {
     for_each = merge(
       { Name = "${var.project_name}-instance-asg" }, # Specific tag for ASG-managed instances
       { Project = var.project_name, Terraform = "true", Tier = "Web/App" }
    )
     content {
       key                 = tag.key
       value               = tag.value
       propagate_at_launch = true
     }
   }

  # Optional: Add scaling policies based on CPU utilization, etc.
  # resource "aws_autoscaling_policy" "scale_up" { ... }
  # resource "aws_autoscaling_policy" "scale_down" { ... }
  # resource "aws_cloudwatch_metric_alarm" "cpu_high" { ... }
  # resource "aws_cloudwatch_metric_alarm" "cpu_low" { ... }


  # Helps prevent issues during updates where instances might be terminated before detaching from LB
  # wait_for_elb_capacity = var.asg_min_size # Wait for at least min_size instances in ELB

  # Use lifecycle rule because name_prefix causes replacement on some changes
  lifecycle {
    create_before_destroy = true
    # Ignore changes to desired_capacity to allow external scaling events (e.g., policies)
    # ignore_changes = [desired_capacity]
  }
}
