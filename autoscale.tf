resource "aws_launch_configuration" "as_conf" {
  name          = "web_config"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
}

resource "aws_autoscaling_group" "as" {
  name                      = "autoscale"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [data.aws_subnet.sub1.id, data.aws_subnet.sub2.id]
}