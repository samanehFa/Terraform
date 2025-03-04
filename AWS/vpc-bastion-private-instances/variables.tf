variable "base_region" {
  type    = string
  default = "ap-northeast-3"
}

variable "ami_image_name" {
  type    = string
  default = ""
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}

