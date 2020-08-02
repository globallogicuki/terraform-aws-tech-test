#*********************************
# Launch Configuration
#*********************************

resource "aws_launch_configuration" "weblc" {
  name_prefix     = "Tech-Test-"
  image_id        = "ami-50c0ea46"
  instance_type   = "t2.small"
  key_name        = aws_key_pair.web.key_name
  security_groups = [aws_security_group.web-instance-security-group.id]
  user_data       = <<EOF
#!/bin/sh
yum install -y nginx
service nginx start
EOF
  lifecycle {
    create_before_destroy = true
  }
}


#*********************************
# AutoScaling Group
#*********************************
resource "aws_autoscaling_group" "web_asg" {
  name                 = "web_asg"
  launch_configuration = aws_launch_configuration.weblc.id
  vpc_zone_identifier  = [ aws_subnet.private-subnet-01.id,aws_subnet.private-subnet-02.id]
  target_group_arns    = [ aws_lb_target_group.tgt.arn ]
  min_size             = 2
  max_size             = 2
  tag {
    key              = "Name"
    value            = "WebAsgNginx"
    propagate_at_launch = true
  }

  tag {
    key              = "Owner"
    value            = var.Owner
    propagate_at_launch = true
  }

  tag {
    key              = "Project"
    value            = var.Project
    propagate_at_launch = true
  }
  depends_on = [aws_nat_gateway.natgw]

}

