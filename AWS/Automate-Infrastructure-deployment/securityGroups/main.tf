resource "aws_security_group" "web-SG" {
  name        = "web-SG"
  vpc_id      = var.vpc_id

  tags = {
    Name = "web_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-HTTP" {
  security_group_id = aws_security_group.web-SG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port  = 80
  ip_protocol = "tcp"
  to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow-SSH" {
  security_group_id = aws_security_group.web-SG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port  = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.web-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}