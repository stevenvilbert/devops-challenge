data "google_dns_managed_zone" "env_dns_zone" {
  name = "svilbert"
}

resource "google_dns_record_set" "app" {
  name         = "${var.domain}."
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  rrdatas      = [var.lb_ip_address]
}

resource "google_dns_record_set" "db" {
  name         = "db.${var.domain}."
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  rrdatas      = [var.is_dr ? var.postgres_replica_endpoint : var.postgres_endpoint]
}
