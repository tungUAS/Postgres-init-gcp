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

// start cloud_sql_instance_private_ip_network
resource "google_compute_network" "vpc-sql-psa-network" {
  name                    = "vpc-sql-psa-network"
  auto_create_subnetworks = "false"
}

// start cloud_sql_instance_private_ip_address
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address-sql-instance-psa"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.peering_network.id
}

// start vpc_sql_instance_private_ip_service_connection
resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.peering_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

// start vpc_sql_instance_private_ip
resource "google_sql_database_instance" "private-sql-instance-psa" {
  name             = "private-sql-instance-psa"
  region           = "europe-west4"
  database_version = "POSTGRES_14"

  depends_on = [google_service_networking_connection.default]

  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.peering_network.id
    }
  }
  deletion_protection = false
}