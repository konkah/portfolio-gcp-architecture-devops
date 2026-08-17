# GCP Architecture and DevOps Reference

Terraform reference project for migrating a public web application from self-managed VMs to Google Cloud. The MVP uses Cloud Run, Cloud SQL, a private VPC, a global HTTPS Load Balancer, Cloud Armor, Secret Manager, DNS, monitoring, and billing alerts.

## Architecture

- **Cloud Run** runs the application container and scales from 1 to 10 instances by default.
- **Cloud SQL for PostgreSQL** is private-IP only and is reachable through the VPC.
- **Serverless VPC Access** connects Cloud Run to the VPC.
- **Cloud NAT** provides outbound internet access for private resources.
- **Global HTTPS Load Balancer** exposes the application and redirects HTTP to HTTPS.
- **Cloud Armor** provides the security policy attached to the load balancer backend.
- **Secret Manager** stores the generated database password.
- **Cloud DNS** manages the application zone and A record.
- **Cloud Monitoring** checks application uptime and sends email alerts.
- **Cloud Billing Budgets** provides budget notifications.

The MVP is deployed in `southamerica-east1` by default and uses a single-zone Cloud SQL instance. High availability, a second region, CDN, Redis, and read replicas are outside the MVP scope.

## Prerequisites

Install and authenticate the following tools:

- Terraform `>= 1.6.0`
- Google Cloud CLI (`gcloud`)
- An active Google Cloud project
- A billing account linked to the project
- A domain whose DNS can be managed at the registrar
- A container image available to Cloud Run

Authenticate locally and select the project:

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

The deploying identity needs permission to create and manage the resources in this project. Project Owner or an equivalent set of administrative roles is required for the initial reference deployment.

## Bootstrap the Terraform State

The GCS backend bucket must exist before Terraform is initialized. Create it outside Terraform, preferably in a dedicated administrative project or in the target project:

```bash
gcloud storage buckets create gs://YOUR_PROJECT_ID-tf-state \
  --project=YOUR_PROJECT_ID \
  --location=us \
  --uniform-bucket-level-access

gcloud storage buckets update gs://YOUR_PROJECT_ID-tf-state \
  --versioning
```

Edit [`main.tf`](main.tf) and replace `REPLACE_WITH_TF_STATE_BUCKET` with the bucket name. The backend prefix is already configured as `portfolio-gcp-architecture-devops`.

Treat the state bucket as sensitive infrastructure. Restrict access to the deployment team and retain object versioning so previous state versions can be recovered.

## Configure Variables

Copy the example file and replace the example values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Required values without defaults are:

- `project_id`
- `cloud_run_image`
- `domain_name`
- `dns_zone_name`
- `alert_email`
- `billing_budget_amount`
- `billing_account_id`

The full list of configurable values is documented directly in [`variables.tf`](variables.tf). Do not commit `terraform.tfvars`, state files, passwords, or other local secrets. The example file is intentionally safe to version.

The image URI should point to a container that already exists, for example:

```text
southamerica-east1-docker.pkg.dev/YOUR_PROJECT_ID/docker/app:latest
```

## Deploy

Initialize the backend and provider:

```bash
terraform init
```

Format and validate the configuration:

```bash
terraform fmt -check
terraform validate
```

Review the proposed infrastructure before applying it:

```bash
terraform plan -var-file=terraform.tfvars
```

Apply the approved plan:

```bash
terraform apply -var-file=terraform.tfvars
```

Terraform enables the required Google Cloud APIs during the deployment. The first apply can take several minutes, especially while creating the private service networking connection, Cloud SQL instance, managed SSL certificate, and monitoring resources.

For repeatable deployments, save and review a plan file:

```bash
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

## Post-Deployment Checklist

1. Get the load balancer IP and DNS nameservers:

   ```bash
   terraform output load_balancer_ip
   terraform output dns_nameservers
   ```

2. At the domain registrar, replace the domain's authoritative nameservers with the values returned by `dns_nameservers`.

3. Confirm that the domain resolves to the load balancer IP:

   ```bash
   dig +short example.com
   ```

4. Wait for the Google-managed SSL certificate to become active. Certificate provisioning requires the domain to resolve correctly to the load balancer and may take several minutes.

5. Test HTTPS and the HTTP redirect:

   ```bash
   curl -I https://example.com
   curl -I http://example.com
   ```

6. Confirm the uptime check and notification channel in Cloud Monitoring.

Useful outputs:

```bash
terraform output
terraform output -raw load_balancer_ip
terraform output -raw cloud_run_service_url
terraform output -raw cloud_sql_private_ip
```

The direct Cloud Run URL is useful for diagnostics, but production traffic should use the HTTPS load balancer and configured domain.

## Security Notes

- Cloud SQL does not expose a public IPv4 address in this configuration.
- The database password is generated by Terraform and stored in Secret Manager.
- Do not print or commit Terraform state: it can contain sensitive values.
- Cloud Run is configured with a public invoker so the load balancer can serve anonymous application traffic. Restrict this only if the application requires authentication.
- The current Cloud Armor policy contains a permissive placeholder rule. Extend it with WAF and rate-based rules before production traffic. The `cloud_armor_rate_limit` and `cloud_armor_rate_limit_duration` variables reserve the intended configuration values but are not applied by the current MVP policy.
- Use separate GCP projects, state buckets, and variable files for different environments.

## Cost Guidance

This is a reference MVP, not a fixed-price deployment. Costs vary with traffic, region, storage, egress, Cloud SQL usage, VPC connector usage, and monitoring volume.

The default configuration is intended for development or low traffic:

- Cloud SQL uses the small `db-f1-micro` tier and a single zone.
- Cloud Run scales down to one instance and up to ten instances.
- The VPC connector starts with two small instances.
- A monthly billing budget and an 80% alert threshold are configured through Terraform.

Review the Google Cloud Pricing Calculator before production use. A budget alert is a notification guardrail; it does not stop resource creation or spending automatically.

## Troubleshooting

### `terraform init` fails because the backend bucket is invalid

Confirm that the bucket exists, that the name in `main.tf` is correct, and that the authenticated identity can access it. Backend bucket names do not include `gs://` in the Terraform configuration.

### Cloud Run cannot start the revision

Confirm that `cloud_run_image` references an existing image, that the image architecture is supported, and that the deploying project has access to Artifact Registry. Check the Cloud Run revision logs in Google Cloud.

### Cloud SQL private networking fails

Check that `vpc_peering_cidr` does not overlap with `subnet_cidr` or another connected network. The Service Networking API must be enabled, and the private service networking connection must complete before the database instance is created.

### The SSL certificate remains provisioning

Check that the registrar points the domain to the Cloud DNS nameservers and that the A record resolves to the load balancer IP. Certificate activation cannot complete while public DNS still points elsewhere.

### Monitoring emails do not arrive

Confirm the email address, check the notification channel in Cloud Monitoring, and complete any verification request sent by Google Cloud.

### Terraform detects unexpected changes

Run `terraform plan` with the same variable file used for the deployment. Avoid editing managed resources manually in the Google Cloud Console; if a manual change is necessary, reconcile it in Terraform afterward.

## Destroying the MVP

Destroying the stack removes the managed infrastructure, including the Cloud SQL instance and its data. Export or back up anything required before running:

```bash
terraform plan -destroy -var-file=terraform.tfvars
terraform destroy -var-file=terraform.tfvars
```

The GCS state bucket is created outside this configuration and is not removed by `terraform destroy`.
