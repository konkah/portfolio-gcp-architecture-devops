# Billing budget and cost threshold notifications.

resource "google_billing_budget" "app" {
  billing_account = "billingAccounts/${var.billing_account_id}"
  display_name    = "${var.env}-budget"

  budget_filter {
    projects = ["projects/${data.google_client_config.current.project}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = var.billing_budget_amount
    }
  }

  threshold_rules {
    threshold_percent = var.billing_alert_threshold / 100
  }

  threshold_rules {
    threshold_percent = 1
  }

  depends_on = [google_project_service.required]
}

data "google_client_config" "current" {}
