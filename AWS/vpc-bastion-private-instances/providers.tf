terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-state-bucket"  
    key            = "terraform.tfstate"          
    region         = "ap-northeast-3"                  
    encrypt        = true               
    dynamodb_table = "terraform-state-lock"       
  }
}

provider "aws" {
  region = var.base_region
}
