  #creating a vpc
resource "aws_vpc" "vic_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "vicvpc"
  }
  
}

                    #creating internet gateway
resource "aws_internet_gateway" "vic_internet_gateway" {
  vpc_id = aws_vpc.vic_vpc.id

  tags = {
    "Name" = "vic-igw"
  }

}

                    #create route table
resource "aws_route_table" "vic_public_rt" {
  vpc_id = aws_vpc.vic_vpc.id

  tags = {
    Name = "vic-public-rt"
  }

}

                    #create route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.vic_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vic_internet_gateway.id

}


                    #creating a subnet
#publicsubnet1
resource "aws_subnet" "vic_public_subnet1" {
  vpc_id                  = aws_vpc.vic_vpc.id
 # count = 3
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    "Name" = "vic-publicsubnet1"
  }

}

#Pu.subnet2
resource "aws_subnet" "vic_public_subnet2" {
  vpc_id                  = aws_vpc.vic_vpc.id
 # count = 3
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"

  tags = {
    "Name" = "vic-publicsubnet2"
  }

}

#Pu.subnet3

resource "aws_subnet" "vic_public_subnet3" {
  vpc_id                  = aws_vpc.vic_vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2c"

  tags = {
    "Name" = "vic-publicsubnet3"
  }

}




                    #create route table associatiom
resource "aws_route_table_association" "vic_route_assoc1" {
  subnet_id      = aws_subnet.vic_public_subnet1.id
  route_table_id = aws_route_table.vic_public_rt.id
}

resource "aws_route_table_association" "vic_route_assoc2" {
  subnet_id      = aws_subnet.vic_public_subnet2.id
  route_table_id = aws_route_table.vic_public_rt.id
}

resource "aws_route_table_association" "vic_route_assoc3" {
  subnet_id      = aws_subnet.vic_public_subnet3.id
  route_table_id = aws_route_table.vic_public_rt.id
}


                    #create security group
resource "aws_security_group" "vic_sg" {
  name        = "vic_sgp"
  description = "vic security group"
  vpc_id      = aws_vpc.vic_vpc.id
  #subnet_ids = [aws_subnet.vic_public_subnet1.id, aws_subnet.vic_public_subnet2.id]

#incoming traffic
  ingress {
    description = "HTTP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
#    security_groups = [aws_security_group.vic_sg.id]
  }
  ingress {
    description = "HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 #   security_groups = [aws_security_group.vic_sg.id]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

#outgoing traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   # ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = "vic_sgp"
  }
}

                  #create keypair
#resource "aws_key_pair" "vic_key" {
 # key_name   = "vickey"
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgX+1lRSGIxC03wWIsGzgMJ/P6zj3D9SGzAFEMt9Dz5 victoria@Kali"
#}

                    #create ec2 instances
#ec2.1
resource "aws_instance" "vic_ec21" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.vic_ami.id
  key_name               = "vickey1"
  vpc_security_group_ids = [aws_security_group.vic_sg.id]
  subnet_id              = aws_subnet.vic_public_subnet1.id
  availability_zone = "us-east-2a" 
  root_block_device {
    volume_size = 10
  }

  tags = {
    "Name" = "vic_ec21"
  }
}

#ec2.2
  resource "aws_instance" "vic_ec22" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.vic_ami.id
  key_name               = "vickey1"
  vpc_security_group_ids = [aws_security_group.vic_sg.id]
  subnet_id              = aws_subnet.vic_public_subnet2.id
  availability_zone = "us-east-2b"
  root_block_device {
    volume_size = 10
  }

  tags = {
    "Name" = "vic_ec22"
  }
}

#ec2.3
resource "aws_instance" "vic_ec23" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.vic_ami.id
  key_name               = "vickey1"
  vpc_security_group_ids = [aws_security_group.vic_sg.id]
  subnet_id              = aws_subnet.vic_public_subnet3.id
  availability_zone = "us-east-2c" 
  root_block_device {
    volume_size = 10
  }

  tags = {
    "Name" = "vic_ec23"
  }
}


#create application load balancer
resource "aws_lb" "vic_alb" {
  name               = "vic-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.vic_sg.id]
  subnets            = [aws_subnet.vic_public_subnet1.id, aws_subnet.vic_public_subnet2.id]
  enable_deletion_protection = false

  tags   = {
    Name = "vic-alb"
  }
}

# create target group
resource "aws_lb_target_group" "alb_target_group" {
  name        = "vic-tg"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vic_vpc.id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.vic_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# create a listener on port 443 with forward action
#resource "aws_lb_listener" "alb_https_listener" {
 # load_balancer_arn  = aws_lb.vic_alb.arn
  #port               = 443
  #protocol           = "HTTPS"
 # ssl_policy         = "ELBSecurityPolicy-2016-08"
  #certificate_arn    = 

 # default_action {
  #  type             = "forward"
   # target_group_arn = aws_lb_target_group.alb_target_group.arn
  #}
#}





                    #route53 zone
resource "aws_route53_zone" "hosted_zone" {
  name = "var.domain_name"
}

resource "aws_route53_record" "vic_r53" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "var.record_name"
  type    = "A"

alias {
    name                   = aws_lb.vic_alb.dns_name
    zone_id                = aws_lb.vic_alb.zone_id
    evaluate_target_health = true
  }
}

#storing ip
resource "local_file" "exporting_ip" {
  filename = "/home/vagrant/Terraform/host-inventory"
  content  = <<EOT
${aws_instance.vic_ec21.public_ip}
${aws_instance.vic_ec22.public_ip}
${aws_instance.vic_ec23.public_ip}
  EOT
}
#resource "aws_route53_record" "subdomain" {
 # zone_id = aws_route53_zone.primary.zone_id
  #name = var.domain.subdomain
  #type = var.domain.type 
 

#alias {
 #   name                   = aws_elb.vic_elb.dns_name
  #  zone_id                = aws_elb.vic_elb.zone_id
   # evaluate_target_health = true
  #}
#}
