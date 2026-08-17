terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Create the GCS state bucket and replace this placeholder before running
  # terraform init. See README.md for the complete bootstrap instructions.

  backend "gcs" {
    bucket = "REPLACE_WITH_TF_STATE_BUCKET"
    prefix = "portfolio-gcp-architecture-devops"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}