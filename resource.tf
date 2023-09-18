resource "google_storage_bucket" "test-bucket-abcxzy-tung" {
  name          = "test-bucket-abcxzy-tung"
  location      = "EU"
  storage_class = "STANDARD"
  project       = var.project_id
}

resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = "vpc-sql-instance"
  auto_create_subnetworks = false
  mtu                     = 1460
}