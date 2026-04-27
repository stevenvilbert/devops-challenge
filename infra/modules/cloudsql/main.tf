resource "google_sql_database" "database" {
  name     = "moonpay-postgres-${var.env}"
  instance = google_sql_database_instance.instance.name
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "instance" {
  name             = "moonpay-postgres-${var.env}-instance"
  region           = "us-central1"
  database_version = var.database_version
  settings {
    tier = var.database_tier
  }

  deletion_protection  = true
}
