output "alb_dns_name" {
  description = "DNS public de l ALB."
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone Route53 alias pour l ALB."
  value       = aws_lb.main.zone_id
}

output "asg_name" {
  description = "Nom de l ASG applicatif."
  value       = aws_autoscaling_group.app.name
}

output "nextcloud_url" {
  description = "URL Nextcloud HTTPS (self-signed : accepter le warning navigateur)."
  value       = "https://${aws_lb.main.dns_name}"
}

output "launch_template_id" {
  description = "ID du Launch Template"
  value       = aws_launch_template.app.id
}

output "target_group_arn" {
  description = "ARN du target group"
  value       = aws_lb_target_group.nextcloud.arn
}