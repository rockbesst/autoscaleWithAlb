# Instances#############################################
resource "aws_instance" "WebServer1" {
	ami = data.aws_ami.amazon_linux.id
	instance_type = var.instance_type
	availability_zone = "eu-central-1a"
	vpc_security_group_ids = [data.aws_security_group.mainSecGroup.id]
	user_data = file("ready_webserver.sh")
	key_name = var.ssh_key
	associate_public_ip_address = var.allow_public_ip
	tags = merge(var.tags, {Name = "WebServer1"})
}
resource "aws_instance" "WebServer2" {
	ami = data.aws_ami.amazon_linux.id
	instance_type = var.instance_type
	availability_zone = "eu-central-1b"
	vpc_security_group_ids = [data.aws_security_group.mainSecGroup.id]
	user_data = file("ready_webserver.sh")
	key_name = var.ssh_key
	associate_public_ip_address = var.allow_public_ip
	tags = merge(var.tags, {Name = "WebServer2"})
}
# AMI Search
data "aws_ami" "amazon_linux" {
	owners = ["amazon"]
	most_recent = true
	filter {
		name = "name"
		values = ["amzn2-ami-hvm-*-x86_64-gp2"]
	}
}