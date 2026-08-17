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
