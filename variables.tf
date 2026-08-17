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
