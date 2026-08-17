# Cloud Run service and its runtime service account.

resource "google_service_account" "cloud_run" {
  account_id   = "${var.env}-cloud-run"
  display_name = "Cloud Run service account"

  depends_on = [google_project_service.required]
}

resource "google_cloud_run_v2_service" "app" {
  name     = "${var.env}-app"
  location = var.region

  template {
    service_account = google_service_account.cloud_run.email

    scaling {
      min_instance_count = var.cloud_run_min_instances
      max_instance_count = var.cloud_run_max_instances
    }

    containers {
      image = var.cloud_run_image

      ports {
        container_port = var.cloud_run_port
      }

      resources {
        limits = {
          memory = var.cloud_run_memory
          cpu    = var.cloud_run_cpu
        }
      }

      env {
        name  = "DATABASE_HOST"
        value = google_sql_database_instance.primary.private_ip_address
      }

      env {
        name  = "DATABASE_PORT"
        value = "5432"
      }

      env {
        name  = "DATABASE_NAME"
        value = var.db_name
      }

      env {
        name  = "DATABASE_USER"
        value = var.db_user
      }

      env {
        name = "DATABASE_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
    }

    vpc_access {
      connector = google_vpc_access_connector.serverless.id
      egress    = "PRIVATE_RANGES_ONLY"
    }
  }

  depends_on = [
    google_vpc_access_connector.serverless,
    google_sql_database_instance.primary,
    google_secret_manager_secret_version.db_password,
    google_service_account.cloud_run,
  ]
}
