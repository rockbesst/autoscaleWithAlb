provider "aws" {
	region = var.region
}

# VPCs#####################################################
data "aws_vpc" "mainVPC" {}
# Load Balancer############################################
resource "aws_lb" "MainLoadBalancer" {
 	name = "MainLoadBalancer"
 	load_balancer_type = "application"
 	security_groups = [data.aws_security_group.mainSecGroup.id]
 	subnets = [data.aws_subnet.sub1.id, data.aws_subnet.sub2.id]
}

 resource "aws_lb_listener" "listener_http" {
   load_balancer_arn = aws_lb.MainLoadBalancer.arn
   port              = "80"
   protocol          = "HTTP"
   default_action {
     type             = "forward"
     target_group_arn = aws_lb_target_group.tg_main.arn
   }
 }
 resource "aws_lb_target_group" "tg_main" {
 	name     = "MainTargetGroup"
   	port     = 80
   	protocol = "HTTP"
   	vpc_id   = data.aws_vpc.mainVPC.id
 }
 resource "aws_lb_target_group_attachment" "attach1_to_tg_main" {
 	target_group_arn = aws_lb_target_group.tg_main.arn
  	target_id        = aws_instance.WebServer1.id
   	port             = 80
  
 }
 resource "aws_lb_target_group_attachment" "attach2_to_tg_main" {
 	target_group_arn = aws_lb_target_group.tg_main.arn
  	target_id        = aws_instance.WebServer2.id
   	port             = 80  
 }

 # Subnets
 data "aws_subnet" "sub1"{
	 id = "subnet-0c95ec66"
 }
 data "aws_subnet" "sub2"{
	 id = "subnet-ad3c88d1"
 }