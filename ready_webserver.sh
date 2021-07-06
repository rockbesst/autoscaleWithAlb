#!/bin/bash
yum -y update
amazon-linux-extras install -y nginx1
ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>Server IP is $ip.</h2>" > /var/www/html/index.html
sudo service nginx start
chkconfig nginx on