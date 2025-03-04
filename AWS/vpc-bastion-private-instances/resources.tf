
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-3c"

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-3b"

  tags = {
    Name = "PrivateSubnet"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "InternetGateway"
  }
}

resource "aws_eip" "ngw" {
  domain = "vpc"

  tags = {
    Name = "NAT-EIP"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    Name = "gwNAT"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "bastion-SG" {
  name        = "Bastion-SG"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "bastion_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "private_ssh_ingress_bastion" {
  security_group_id = aws_security_group.bastion-SG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port  = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "private_outbound_bastion" {
  security_group_id = aws_security_group.bastion-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_key_pair" "key" {
  key_name = ""
}

resource "aws_instance" "bastion" {
  ami = var.ami_image_name
  instance_type = var.instance_type
  subnet_id = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.bastion-SG.id]
  tags = {
    Name = "bastion-Host"
  }
}


resource "aws_security_group" "private_sg" {
  name        = "private_instance"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "private_instance_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "private_ssh_ingress" {
  security_group_id        = aws_security_group.private_sg.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port               = 22
  ip_protocol             = "tcp"
  to_port                 = 22
}

resource "aws_vpc_security_group_egress_rule" "private_outbound" {
  security_group_id = aws_security_group.private_sg.id
  cidr_ipv4         = "10.0.2.0/24" 
  ip_protocol       = "-1"
}

resource "aws_instance" "private_instance" {
  ami = var.ami_image_name
  instance_type = var.instance_type
  subnet_id = aws_subnet.private_subnet.id
  associate_public_ip_address = false
  key_name = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "private_instance"
  }
}

resource "null_resource" "bastion_connection" {

  provisioner "local-exec" {
      command = <<EOT
        echo "Copying private key to Bastion..."
        scp -o StrictHostKeyChecking=no -i /path/to/key.pem /path/to/key.pem ubuntu@${aws_instance.bastion.public_ip}:~/
      EOT
    }
  provisioner "remote-exec" {
    inline = [
      "echo 'Setting correct permissions for the private key on Bastion'",
      "chmod 400 ~/key.pem",
      "echo 'Connecting to the private instance...'",
      "ssh -o StrictHostKeyChecking=no -i ~/key.pem ubuntu@${aws_instance.private_instance.private_ip} echo 'Connection successful!'"
    ]
  }

  connection {
    host = aws_instance.bastion.public_ip
    user = "ubuntu"
    private_key = file("/path/to/key.pem")
  }
}

locals {
  private_key_path = "/path/to/key.pem"
}

