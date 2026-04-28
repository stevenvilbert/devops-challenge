output "postgres_endpoint" {
  value = google_sql_database_instance.instance.private_ip_address
}
