resource "google_storage_bucket" "test-bucket-abcxzy-tung" {
  name          = "test-bucket-abcxzy-tung"
  location      = "EU"
  storage_class = "STANDARD"
  project       = var.project_id
}

resource "google_sql_database_instance" "sql-instance-abcxzy-tung" {
  name             = "sql-instance-abcxzy-tung"
  region           = "europe-west4"
  database_version = "POSTGRES_14"
  root_password    = "abcABC123!"
  settings {
    tier = "db-custom-2-7680"
    password_validation_policy {
      min_length                  = 6
      reuse_interval              = 2
      complexity                  = "COMPLEXITY_DEFAULT"
      disallow_username_substring = true
      password_change_interval    = "30s"
      enable_password_policy      = true
    }
  }
  deletion_protection = false
}

// psc_config not expected here
// https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
// psc instance creation only via rest or gcloud
/* resource "google_sql_database_instance" "sql-instance-psc-tung" {
  name             = "sql-instance-psc-tung"
  region           = "europe-west4"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = ["cst-pbag-aiml-test"]
      }
      ipv4_enabled = false
    }
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }
    availability_type = "REGIONAL"
  }
} */