provider "aws" {
  region = "me-central-1"
}

module "vpc" {
  source     = "./VPC"
}

module "subnets" {
  source             = "./Subnets"
  vpc_id = module.vpc.vpc_id 
}

module "security_groups" {
  source = "./Security-groups"
  vpc_id = module.vpc.vpc_id 
}

module "gateways" {
  source = "./Gateways"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
}