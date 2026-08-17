resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  name                  = "${var.env}-cloud-run-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  network               = google_compute_network.vpc.id

  cloud_run {
    service = google_cloud_run_v2_service.app.name
  }

  depends_on = [google_cloud_run_v2_service.app]
}
