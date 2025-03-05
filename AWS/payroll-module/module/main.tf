resource "aws_instance" "payroll_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "Payroll-Server"
  }
}

resource "aws_s3_bucket" "payroll_docs" {
  bucket = var.s3_bucket
}

resource "aws_dynamodb_table" "payroll_db" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "EmployeeID"

  attribute {
    name = "EmployeeID"
    type = "S"
  }
}
