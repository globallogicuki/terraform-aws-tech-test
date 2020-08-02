#*********************************
# ELB Setup 
#*********************************

resource "aws_lb" "ALB" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public-subnet-01.id,aws_subnet.public-subnet-02.id]
  security_groups    = [aws_security_group.web-instance-security-group.id]
  tags = {
    Name = "Jump Host"
    Owner = var.Owner
    Project = var.Project
  }

}




#*********************************
# Target Grp Setup 
#*********************************
resource "aws_lb_target_group" "tgt" {
  name            = "tgt-healhchk"
  protocol        = "HTTP"
  vpc_id          = aws_vpc.vpc.id
  port            = 80
   health_check {
    path     = "/"
    matcher  = "200"
    protocol = "HTTP"
  }
  tags = {
    Owner = var.Owner
    Project = var.Project
  }

}

resource "aws_lb_listener" "ALB-listener" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
  type             = "forward"
  target_group_arn = aws_lb_target_group.tgt.arn
  }

}


#*********************************
# DNS name for ELB 
#*********************************

output "elb-dns" {
  value = aws_lb.ALB.dns_name
}
