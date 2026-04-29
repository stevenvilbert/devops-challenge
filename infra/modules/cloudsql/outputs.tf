output "postgres_endpoint" {
  value = google_sql_database_instance.instance.private_ip_address
}

output "postgres_replica_endpoint" {
  value = google_sql_database_instance.read_replica.private_ip_address
}
