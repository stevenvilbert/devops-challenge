output "password" {
  value     = random_password.db_password.result
  sensitive = true # Protects from console output
}
