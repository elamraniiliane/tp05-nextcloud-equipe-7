# Launch Template : la recette pour créer nos EC2
resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-nc-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.app_instance_profile_name
  }

  vpc_security_group_ids = [var.app_security_group_id]

  user_data = base64encode(templatefile(
    "${path.module}/templates/nextcloud-user-data.sh.tftpl",
    {
      aws_region                = data.aws_region.current.name
      db_endpoint               = var.db_endpoint
      db_name                   = var.db_name
      db_username               = var.db_username
      db_password_secret_arn    = var.db_password_secret_arn
      admin_password_secret_arn = var.admin_password_secret_arn
      s3_bucket                 = var.s3_primary_bucket_name
    }
  ))

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-nextcloud"
    })
  }

  update_default_version = true

  tags = local.common_tags
}

# Auto Scaling Group - maintient l'EC2 en vie
resource "aws_autoscaling_group" "app" {
  name_prefix         = "${local.name_prefix}-nc-"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = local.private_app_subnet_ids_list
  target_group_arns   = [aws_lb_target_group.nextcloud.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-nextcloud"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
}

# Rattachement ASG <-> Target Group
resource "aws_autoscaling_attachment" "app_tg" {
  autoscaling_group_name = aws_autoscaling_group.app.name
  lb_target_group_arn    = aws_lb_target_group.nextcloud.arn
}