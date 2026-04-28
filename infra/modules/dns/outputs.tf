output "dns_zone_name" {
  value = data.google_dns_managed_zone.env_dns_zone.name
}

output "dns_name" {
  value = data.google_dns_managed_zone.env_dns_zone.dns_name
}
