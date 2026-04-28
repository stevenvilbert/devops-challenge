data "google_dns_managed_zone" "env_dns_zone" {
  name = "svilbert"
  project = var.project
}

resource "google_dns_record_set" "app" {
  name         = "${var.domain}."
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  rrdatas      = [var.lb_ip_address]
}
