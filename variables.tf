variable "project_id" {
  description = "The Google Cloud project ID where the infrastructure is deployed."
  type        = string
}

variable "region" {
  description = "The primary Google Cloud region for the MVP deployment."
  type        = string
  default     = "southamerica-east1"
}

variable "env" {
  description = "The environment name used for resource naming."
  type        = string
  default     = "dev"
}

variable "subnet_cidr" {
  description = "CIDR block for the primary subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpc_peering_cidr" {
  description = "CIDR block reserved for VPC Peering with Google Services (Cloud SQL)."
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_connector_machine_type" {
  description = "Machine type for the Serverless VPC Access Connector."
  type        = string
  default     = "e2-micro"
}

variable "vpc_connector_min_instances" {
  description = "Minimum instances for the Serverless VPC Access Connector."
  type        = number
  default     = 2
}

variable "db_instance_name" {
  description = "Name of the Cloud SQL instance."
  type        = string
  default     = "app-db"
}

variable "db_version" {
  description = "Database version (e.g., POSTGRES_15)."
  type        = string
  default     = "POSTGRES_15"
}

variable "db_tier" {
  description = "Machine tier for the Cloud SQL instance."
  type        = string
  default     = "db-f1-micro"
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "db_user" {
  description = "Initial database user."
  type        = string
  default     = "appuser"
}

variable "artifact_repository_id" {
  description = "Artifact Registry repository ID."
  type        = string
  default     = "docker"
}

variable "artifact_repository_format" {
  description = "Artifact Registry repository format."
  type        = string
  default     = "DOCKER"
}

variable "cloud_run_image" {
  description = "Container image URI for Cloud Run."
  type        = string
}

variable "cloud_run_port" {
  description = "Port exposed by the container."
  type        = number
  default     = 8080
}

variable "cloud_run_memory" {
  description = "Memory allocation for Cloud Run instances."
  type        = string
  default     = "512Mi"
}

variable "cloud_run_cpu" {
  description = "CPU allocation for Cloud Run instances."
  type        = string
  default     = "1"
}

variable "cloud_run_min_instances" {
  description = "Minimum number of Cloud Run instances."
  type        = number
  default     = 1
}

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances."
  type        = number
  default     = 10
}

variable "cloud_armor_rate_limit" {
  description = "Rate limit threshold per IP (requests per 10 seconds)."
  type        = number
  default     = 100
}

variable "cloud_armor_rate_limit_duration" {
  description = "Duration for rate limit enforcement in seconds."
  type        = number
  default     = 600
}

variable "domain_name" {
  description = "Domain name for the application (e.g., example.com)."
  type        = string
}

variable "dns_zone_name" {
  description = "DNS zone name (usually the domain without www prefix, e.g., example.com)."
  type        = string
}

variable "alert_email" {
  description = "Email address for monitoring alerts."
  type        = string
}

variable "uptime_check_path" {
  description = "Path for uptime check (e.g., /health)."
  type        = string
  default     = "/"
}

variable "billing_budget_amount" {
  description = "Monthly budget limit in USD."
  type        = number
}

variable "billing_alert_threshold" {
  description = "Alert threshold as percentage of budget (e.g., 80 for 80%)."
  type        = number
  default     = 80
}

variable "billing_account_id" {
  description = "GCP Billing Account ID (format: XXXXXX-XXXXXX-XXXXXX)."
  type        = string
}
