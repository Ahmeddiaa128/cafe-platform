output "address" {
  description = "RDS hostname (no port), used as /cafe/dbUrl"
  value       = aws_db_instance.db.address
}

output "port" {
  value = aws_db_instance.db.port
}