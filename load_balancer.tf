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

resource "google_compute_security_policy" "cloud_armor" {
  name        = "${var.env}-cloud-armor"
  description = "Cloud Armor policy for DDoS protection and rate limiting"

  rule {
    action      = "allow"
    priority    = "1000"
    description = "Default allow rule"

    match {
      versioned_expr = "SRC_IPS_V1"
      expr {
        expression = "*"
      }
    }
  }

  depends_on = [google_project_service.required]
}

resource "google_compute_backend_service" "app" {
  name                            = "${var.env}-backend-service"
  protocol                        = "HTTPS"
  enable_cdn                      = false
  security_policy                 = google_compute_security_policy.cloud_armor.id
  load_balancing_scheme           = "EXTERNAL"
  port_name                       = "http"
  session_affinity                = "NONE"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 300

  backend {
    group                 = google_compute_region_network_endpoint_group.cloud_run_neg.id
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 10
  }

  depends_on = [
    google_compute_region_network_endpoint_group.cloud_run_neg,
    google_compute_security_policy.cloud_armor,
  ]
}

resource "google_compute_url_map" "app" {
  name            = "${var.env}-url-map"
  default_service = google_compute_backend_service.app.id

  depends_on = [google_compute_backend_service.app]
}

resource "google_compute_managed_ssl_certificate" "app" {
  name        = "${var.env}-ssl-cert"
  description = "Managed SSL certificate for the application"
  managed {
    domains = [var.domain_name]
  }

  depends_on = [google_project_service.required]
}

resource "google_compute_target_https_proxy" "app" {
  name             = "${var.env}-https-proxy"
  url_map          = google_compute_url_map.app.id
  ssl_certificates = [google_compute_managed_ssl_certificate.app.id]

  depends_on = [
    google_compute_url_map.app,
    google_compute_managed_ssl_certificate.app,
  ]
}

resource "google_compute_global_address" "lb" {
  name         = "${var.env}-lb-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  depends_on = [google_project_service.required]
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.env}-https-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_https_proxy.app.id
  ip_address            = google_compute_global_address.lb.id

  depends_on = [
    google_compute_target_https_proxy.app,
    google_compute_global_address.lb,
  ]
}
