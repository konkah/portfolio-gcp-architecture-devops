resource "google_monitoring_notification_channel" "email" {
  display_name = "${var.env}-email-alert"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
  enabled = true

  depends_on = [google_project_service.required]
}

resource "google_monitoring_uptime_check_config" "app" {
  display_name = "${var.env}-uptime-check"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path    = var.uptime_check_path
    port    = 443
    use_ssl = true
  }

  monitored_resource {
    type = "uptime-url"
    labels = {
      host = var.domain_name
    }
  }

  selected_regions = ["USA", "EUROPE", "ASIA_PACIFIC"]

  depends_on = [
    google_dns_record_set.app,
    google_project_service.required,
  ]
}

resource "google_monitoring_alert_policy" "app_down" {
  display_name = "${var.env}-app-down-alert"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Uptime check failed"

    condition_threshold {
      filter          = "resource.type = \"uptime-url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.labels.host = \"${var.domain_name}\""
      duration        = "60s"
      comparison      = "COMPARISON_LT"
      threshold_value = 1
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_FRACTION_TRUE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]

  depends_on = [
    google_monitoring_uptime_check_config.app,
    google_monitoring_notification_channel.email,
  ]
}
