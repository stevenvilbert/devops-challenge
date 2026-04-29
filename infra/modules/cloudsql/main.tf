resource "google_sql_database" "database" {
  name     = "moonpay-postgres-${var.env}"
  instance = google_sql_database_instance.instance.name
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "instance" {
  name             = "moonpay-postgres-${var.env}-instance"
  region           = var.region
  database_version = var.database_version
  settings {
    tier = var.database_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }

  deletion_protection = true
}

resource "google_sql_database_instance" "read_replica" {
  name                 = "moonpay-postgres-${var.env}-replica"
  master_instance_name = google_sql_database_instance.instance.name
  region               = var.cloudsql_replication_region
  database_version     = var.database_version

  replica_configuration {
    failover_target = false
  }

  settings {
    tier = var.database_tier
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }

  deletion_protection = true
}


data "google_secret_manager_secret_version" "pg_pw" {
  secret = "POSTGRES_PASSWORD"
}

data "google_secret_manager_secret_version" "pg_user" {
  secret = "POSTGRES_USER"
}



resource "google_sql_user" "user" {
  name     = data.google_secret_manager_secret_version.pg_user.secret_data
  instance = google_sql_database_instance.instance.name
  password = data.google_secret_manager_secret_version.pg_pw.secret_data
}
