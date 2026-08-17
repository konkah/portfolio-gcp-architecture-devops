output "load_balancer_ip" {
  description = "Public IP address of the Load Balancer"
  value       = google_compute_global_address.lb.address
}

output "dns_nameservers" {
  description = "Nameservers for the DNS zone (update your domain registrar with these)"
  value       = google_dns_managed_zone.app.name_servers
}

output "cloud_run_service_url" {
  description = "Direct URL to the Cloud Run service"
  value       = google_cloud_run_v2_service.app.uri
}

output "cloud_sql_instance_name" {
  description = "Cloud SQL instance name"
  value       = google_sql_database_instance.primary.name
}

output "cloud_sql_private_ip" {
  description = "Private IP address of Cloud SQL instance"
  value       = google_sql_database_instance.primary.private_ip_address
}

output "artifact_registry_repository_url" {
  description = "Artifact Registry repository URL for container images"
  value       = "${google_artifact_registry_repository.docker.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}"
}

output "domain_name" {
  description = "Application domain name"
  value       = var.domain_name
}

output "monitoring_uptime_check_id" {
  description = "Monitoring uptime check configuration ID"
  value       = google_monitoring_uptime_check_config.app.id
}
