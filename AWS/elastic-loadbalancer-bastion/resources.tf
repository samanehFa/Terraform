data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet" "private" {
  id = var.subnet_id_private
}


data "aws_subnet" "public1" {
  id = var.subnet_id_public1
}


data "aws_subnet" "public2" {
  id = var.subnet_id_public2
}


resource "aws_security_group" "alb-sg" {
  name        = "lb-sg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "alb_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-HTTP_lb" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port  = 80
  ip_protocol = "tcp"
  to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow-HTTPS_lb" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port  = 443
  ip_protocol = "tcp"
  to_port = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_lb" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_security_group" "web-server-sg" {
  name        = "web-SG"
  vpc_id      = var.vpc_id

  tags = {
    Name = "web_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-HTTP" {
  security_group_id = aws_security_group.web-server-sg.id
  referenced_security_group_id = aws_security_group.alb-sg.id
  from_port  = 80
  ip_protocol = "tcp"
  to_port = 80
}
 

resource "aws_vpc_security_group_ingress_rule" "allow-SSH" {
  security_group_id = aws_security_group.web-server-sg.id
  referenced_security_group_id = aws_security_group.bastion-SG.id
  from_port  = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.web-server-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_key_pair" "key" {
  key_name = ""
}

resource "aws_security_group" "bastion-SG" {
  name        = "Bastion-SG"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "private_ssh_ingress_bastion" {
  security_group_id = aws_security_group.bastion-SG.id
  cidr_ipv4 = "you own ip"
  from_port  = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "private_outbound_bastion" {
  security_group_id = aws_security_group.bastion-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_instance" "bastion" {
  ami = var.ami_image
  instance_type = var.instance_type
  subnet_id = data.aws_subnet.public1.id
  associate_public_ip_address = true
  key_name = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.bastion-SG.id]
  tags = {
    Name = "bastion-Host"
  }
}

resource "aws_instance" "ec2-instance1" {
  ami = var.ami_image
  instance_type = var.instance_type
  key_name = data.aws_key_pair.key.key_name
  subnet_id = var.subnet_id_private
  vpc_security_group_ids = [aws_security_group.web-server-sg.id]
  tags = {
    Name = "ec2-1"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "echo '<h1>This is Server 1</h1>' | sudo tee /var/www/html/index.html",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/path/to/key.pem")
    host        = self.private_ip 
    bastion_host = aws_instance.bastion.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = file("/path/to/key.pem")
  }
}


resource "aws_instance" "ec2-instance2" {
  ami = var.ami_image
  instance_type = var.instance_type
  key_name = data.aws_key_pair.key.key_name
  subnet_id = var.subnet_id_private
  vpc_security_group_ids = [aws_security_group.web-server-sg.id]
  tags = {
    Name = "ec2-2"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "echo '<h1>This is Server 2</h1>' | sudo tee /var/www/html/index.html",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/path/to/key.pem.pem")
    host        = self.private_ip 
    bastion_host = aws_instance.bastion.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = file("/path/to/key.pem.pem")
  }
}


resource "aws_lb_target_group" "web-servers" {
  name     = "web-servers"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "attachment1" {
  target_group_arn = aws_lb_target_group.web-servers.arn
  target_id        = aws_instance.ec2-instance1.id
  port            = 80
}

resource "aws_lb_target_group_attachment" "attachment2" {
  target_group_arn = aws_lb_target_group.web-servers.arn
  target_id        = aws_instance.ec2-instance2.id
  port            = 80
}

resource "aws_lb" "web_load_balancer" {
  name               = "web-load-balancer"
  internal           = false  
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]  
  subnets           = [data.aws_subnet.public1.id, data.aws_subnet.public2.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-servers.arn
  }
}