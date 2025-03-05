module "payroll" {
  source              = "./modules/payroll"
  ami_id              = "ami-053e5b2b49d1b2a82"
  instance_type       = "t3.micro"
  s3_bucket      = "payroll-docs-ap-northeast-3-samaneh"
  dynamodb_table = "PayrollDB-samaneh"
}
