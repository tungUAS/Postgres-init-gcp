module "test-vpc-module" {
  source                  = "terraform-google-modules/network/google"
  version                 = "~> 7.0"
  project_id              = var.project_id
  network_name            = "vpc-sql-instance"
  auto_create_subnetworks = false
  mtu                     = 1460

  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = var.region
    },
    {
      subnet_name   = "subnet-02"
      subnet_ip     = "10.10.20.0/24"
      subnet_region = var.region
    },
  ]
}