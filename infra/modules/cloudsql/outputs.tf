output "postgres_endpoint" {
  value = google_sql_database_instance.instance.ip_address
}
