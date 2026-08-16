variable "project_id" {
  description = "The Google Cloud project ID where the infrastructure is deployed."
  type        = string
}

variable "region" {
  description = "The primary Google Cloud region for the MVP deployment."
  type        = string
  default     = "southamerica-east1"
}