variable "vpc_id" {
    description = " VPC id of an existing vpc"
    type = string
}

variable "ami_image" {
    description = "ami image of the instances"
    type = string
}

variable "instance_type" {
    description = "type of the image"
    type= string
}

variable "base_region" {
    description = "amazon region"
    type = string
}

variable "subnet_id_private" {
    description = "private subnet id for the instances"
    type = string
}

variable "subnet_id_public1" {
    description = "public subnet id for lb"
    type = string

}

variable "subnet_id_public2" {
    description = "public subnet id for lb"
    type = string
}