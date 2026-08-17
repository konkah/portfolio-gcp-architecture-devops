# Cloud Router and NAT for outbound internet access from the VPC.

resource "google_compute_router" "nat" {
  name    = "${var.env}-router"
  network = google_compute_network.vpc.id
  region  = var.region

  depends_on = [google_compute_subnetwork.primary]
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.env}-router-nat"
  router                             = google_compute_router.nat.name
  region                             = google_compute_router.nat.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  depends_on = [google_compute_router.nat]
}
