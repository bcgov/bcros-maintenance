terraform {
  cloud {
    organization = "BCRegistry"
    workspaces {
      name = "gcp-iam"
    }
  }
}

provider "google" {
  project = null
  region  = var.region
}

module "iam" {
  for_each = var.projects  # Iterate over all projects

  source           = "./modules/iam"
  project_id       = each.value.project_id
  service_accounts = each.value.service_accounts
  custom_roles     = each.value.custom_roles
}
