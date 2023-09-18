resource "google_storage_bucket" "test-bucket" {
  name          = "test-bucket"
  location      = "EU"
  storage_class = "STANDARD"
  project       = var.project_id
}