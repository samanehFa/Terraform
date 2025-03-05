output "ec2_instance_id" {
  value = aws_instance.payroll_server.id
}

output "s3_bucket" {
  value = aws_s3_bucket.payroll_docs.id
}

output "dynamodb_table" {
  value = aws_dynamodb_table.payroll_db.name
}
