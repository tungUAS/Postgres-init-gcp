terraform {
  cloud {
    organization = "TFC-Practice"

    hostname = "app.terraform.io"

    workspaces {
      name = "TFC-Senacor"
    }
  }

  required_providers {
    github = {
      source = "integrations/github"
    }

    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }

  required_version = ">= 0.14"
}