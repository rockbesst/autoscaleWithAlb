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
  #protect_from_scale_in     = true
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [data.aws_subnet.sub1.id, data.aws_subnet.sub2.id]
  target_group_arns = [aws_lb_target_group.tg_main.arn]
}

resource "aws_autoscaling_policy" "as_policy" {
    name = "scale_policy"
    policy_type = "TargetTrackingScaling"
    autoscaling_group_name = aws_autoscaling_group.as.name
    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
            }
        target_value = "70"
    }
}