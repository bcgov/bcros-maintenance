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
  credentials = var.GOOGLE_CREDENTIALS
}

locals {
  default_environment = {
    environment_service_accounts = {}
    environment_custom_roles     = {}
  }
}

module "iam" {
  for_each = var.projects

  source           = "./modules/iam"
  project_id       = each.value.project_id
  env              = lookup(var.environments, each.value.env, local.default_environment)
  service_accounts = each.value.service_accounts
  custom_roles     = each.value.custom_roles
  global_service_accounts = var.global_service_accounts
  global_custom_roles = var.global_custom_roles
}
