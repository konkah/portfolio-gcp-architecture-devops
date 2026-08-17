resource "google_dns_managed_zone" "app" {
  name        = "${var.env}-dns-zone"
  description = "DNS zone for the application domain"
  dns_name    = "${var.dns_zone_name}."

  depends_on = [google_project_service.required]
}

resource "google_dns_record_set" "app" {
  name         = var.domain_name
  managed_zone = google_dns_managed_zone.app.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.lb.address]

  depends_on = [
    google_dns_managed_zone.app,
    google_compute_global_address.lb,
  ]
}
