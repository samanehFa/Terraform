resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_eip" "ngw" {
  domain = "vpc"

  tags = {
    Name = var.eip_ngw
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id = var.public_subnet_ids[0]

  tags = {
    Name = var.ngw_name
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = var.private_rt_name
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public_rt_name
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  count = length(var.public_subnet_ids)
  subnet_id     = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_assoc" {
  count = length(var.private_subnet_ids)
  subnet_id     = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private_rt.id
}
