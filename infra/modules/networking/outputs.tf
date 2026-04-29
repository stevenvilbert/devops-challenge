output "network_id" {
  value = google_compute_network.vpc_network.id
}

output "network_name" {
  value = google_compute_network.vpc_network.name
}

output "subnetwork_name" {
  value = google_compute_subnetwork.subnet1.name
}

output "dr_subnetwork_name" {
  value = google_compute_subnetwork.subnet2.name
}

output "service_networking_connection" {
  value = google_service_networking_connection.private_vpc_connection
}

output "lb_ip_address" {
  value = google_compute_global_address.lb_ip.address
}

output "ssl_policy_name" {
  value = google_compute_ssl_policy.modern.name
}

output "ssl_certificate_name" {
  value = google_compute_managed_ssl_certificate.default.name
}
