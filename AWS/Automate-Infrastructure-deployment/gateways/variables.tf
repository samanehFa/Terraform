variable "public_subnet_ids" {
    description = "The id of the public subnet"
}

variable "private_subnet_ids" {
    description = "The id of the private subnet"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "igw_name" {
    description = "name of the internet gateway"
    type = string
    default = "Samaneh-InternetGateway"
}

variable "ngw_name" {
    description = "name of the nat gateway"
    type = string
    default = "Samaneh-gwNAT"
}

variable "eip_ngw" {
    description = "name of the nat gateway elastic ip"
    type = string
    default = "Samaneh-NAT-EIP"
}

variable "public_rt_name" {
    description = "name of the public route table"
    type = string
    default = "PublicRouteTable"
}

variable "private_rt_name" {
    description = "name of the private route table"
    type = string
    default = "PrivateRouteTable"
}
