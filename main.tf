terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }

  # GCS Backend Configuration for Terraform State
  # =============================================
  # Before running 'terraform init', create a GCS bucket for state:
  #
  # 1. Create the bucket:
  #    gcloud storage buckets create gs://YOUR-PROJECT-ID-tf-state \
  #      --project=YOUR-PROJECT-ID \
  #      --location=us \
  #      --uniform-bucket-level-access
  #
  # 2. Enable versioning for state safety:
  #    gcloud storage buckets update gs://YOUR-PROJECT-ID-tf-state \
  #      --versioning
  #
  # 3. Replace 'REPLACE_WITH_TF_STATE_BUCKET' below with your bucket name
  #    (e.g., 'my-project-id-tf-state')
  #
  # 4. Then run: terraform init
  #

  backend "gcs" {
    bucket = "REPLACE_WITH_TF_STATE_BUCKET"
    prefix = "portfolio-gcp-architecture-devops"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}