provider "github" {}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  credentials = jsondecode(var.google_credentials)
}