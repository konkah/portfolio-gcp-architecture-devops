# Private service networking range and VPC peering for Cloud SQL.

resource "google_compute_global_address" "vpc_peering" {
  name          = "${var.env}-vpc-peering-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id

  depends_on = [google_compute_network.vpc]
}

resource "google_service_networking_connection" "private_service" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.vpc_peering.name]

  depends_on = [google_compute_global_address.vpc_peering]
}
