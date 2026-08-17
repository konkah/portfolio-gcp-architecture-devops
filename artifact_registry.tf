# Artifact Registry repository for application container images.

resource "google_artifact_registry_repository" "docker" {
  location      = var.region
  repository_id = "${var.env}-${var.artifact_repository_id}"
  format        = var.artifact_repository_format
  description   = "Docker repository for application container images"

  depends_on = [google_project_service.required]
}
