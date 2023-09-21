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

# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

resource "google_compute_instance" "instance-vm-sql-psa" {
  boot_disk {
    auto_delete = true
    device_name = "instance-vm-sql-psa"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20230912"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-micro"
  name         = "instance-vm-sql-psa"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    network = "projects/cst-pbag-aiml-test/global/networks/default"
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    subnetwork = "projects/cst-pbag-aiml-test/regions/europe-west4/subnetworks/subnet-vpc-sql-psa"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "507085571061-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = "europe-west4-a"
}
