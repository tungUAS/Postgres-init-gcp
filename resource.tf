// start cloud_sql_instance_private_ip_address
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address-sql-instance-psa"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc-sql-module.network_name
}

// start vpc_sql_instance_private_ip_service_connection
resource "google_service_networking_connection" "default" {
  network                 = module.vpc-sql-module.network_name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

// start vpc_sql_instance_private_ip
resource "google_sql_database_instance" "sql-instance-psa" {
  name             = "sql-instance-psa"
  region           = "europe-west4"
  database_version = "POSTGRES_14"

  depends_on = [google_service_networking_connection.default]

  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = "projects/${var.project_id}/global/networks/${module.vpc-sql-module.network_name}"
    }
  }
  deletion_protection = false
}

// start private internal IP address for the endpoint.
resource "google_compute_address" "psc_endpoint_ip" {
  address_type = "INTERNAL"
  name         = "private-ip-psc-sql-endpoint"
  purpose      = "GCE_ENDPOINT"
  region       = var.region
  subnetwork   = "subnet-vpc-sql-psc"
}

// start endpoint
resource "google_compute_forwarding_rule" "psc-sql-endpoint" {
  ip_address = google_compute_address.psc_endpoint_ip.self_link
  name       = "psc-sql-endpoint"
  network    = module.vpc-sql-psc-module.network_name
  region     = var.region
  load_balancing_scheme = ""
  target     = var.service_attachment
}