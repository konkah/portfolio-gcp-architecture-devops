resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "google_sql_database_instance" "primary" {
  name             = "${var.env}-${var.db_instance_name}"
  database_version = var.db_version
  region           = var.region

  settings {
    tier              = var.db_tier
    availability_type = "ZONAL"
    backup_configuration {
      enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
  }

  deletion_protection = false

  depends_on = [google_service_networking_connection.private_service]
}

resource "google_sql_database" "app" {
  name     = var.db_name
  instance = google_sql_database_instance.primary.name

  depends_on = [google_sql_database_instance.primary]
}

resource "google_sql_user" "app" {
  name     = var.db_user
  instance = google_sql_database_instance.primary.name
  password = random_password.db_password.result

  depends_on = [google_sql_database_instance.primary]
}
