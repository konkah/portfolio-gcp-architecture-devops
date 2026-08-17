resource "google_compute_network" "vpc" {
  name                    = "${var.env}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.required]
}

resource "google_compute_subnetwork" "primary" {
  name          = "${var.env}-subnet-primary"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  depends_on = [google_compute_network.vpc]
}

resource "google_vpc_access_connector" "serverless" {
  name          = "${var.env}-vpc-connector"
  region        = var.region
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.name
  machine_type  = var.vpc_connector_machine_type
  min_instances = var.vpc_connector_min_instances

  depends_on = [google_compute_subnetwork.primary]
}
