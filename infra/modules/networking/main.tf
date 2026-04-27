resource "google_compute_network" "vpc_network" {
  name = "moonpay-vpc"
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "moonpay-vpc"
  ip_cidr_range = "10.16.0.0/22"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

# Reserve a private IP range for Google-managed services (Cloud SQL)
resource "google_compute_global_address" "private_ip_range" {
  name          = "moonpay-private-ip-range-${var.env}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = google_compute_network.vpc_network.id
}

# Establish private services access peering
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

# Allow GKE nodes to reach Cloud SQL on port 5432 only
resource "google_compute_firewall" "allow_gke_to_cloudsql" {
  name    = "allow-gke-to-cloudsql-${var.env}"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  direction     = "EGRESS"
  destination_ranges = [google_compute_global_address.private_ip_range.address]
  target_tags   = ["gke-moonpay-${var.env}"]
}

# Deny all other traffic from GKE nodes to the Cloud SQL private range
resource "google_compute_firewall" "deny_gke_to_cloudsql_other" {
  name    = "deny-gke-to-cloudsql-other-${var.env}"
  network = google_compute_network.vpc_network.name

  deny {
    protocol = "all"
  }

  direction          = "EGRESS"
  destination_ranges = [google_compute_global_address.private_ip_range.address]
  priority           = 65534
}
