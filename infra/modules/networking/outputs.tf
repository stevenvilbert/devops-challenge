output "network_id" {
  value = google_compute_network.vpc_network.id
}

output "network_name" {
  value = google_compute_network.vpc_network.name
}

output "subnetwork_name" {
  value = google_compute_subnetwork.subnet1.name
}

output "service_networking_connection" {
  value = google_service_networking_connection.private_vpc_connection
}
