resource "google_secret_manager_secret_iam_member" "cloud_run_secret_access" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"

  depends_on = [
    google_secret_manager_secret.db_password,
    google_service_account.cloud_run,
  ]
}
