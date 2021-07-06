resource "aws_launch_configuration" "as_conf" {
    name          = "web_config"
    image_id      = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    user_data = file("ready_webserver.sh")
    key_name = var.ssh_key
}

resource "aws_autoscaling_group" "as" {
  name                      = "autoscale"
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [data.aws_subnet.sub1.id, data.aws_subnet.sub2.id]
  target_group_arns = [aws_lb_target_group.tg_main.arn]
}

resource "aws_autoscaling_policy" "as_up" {
    name = "agents-scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.as.name
}

resource "aws_autoscaling_policy" "as_down" {
    name = "agents-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.as.name
}

resource "aws_cloudwatch_metric_alarm" "trigger_as_up" {
  alarm_name          = "trigger_as_up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description = "This metric monitors ec2 cpu utilization and trigger upscaling"
  alarm_actions     = [aws_autoscaling_policy.as_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "trigger_as_down" {
  alarm_name          = "trigger_as_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description = "This metric monitors ec2 cpu utilization and trigger downscaling"
  alarm_actions     = [aws_autoscaling_policy.as_down.arn]
}