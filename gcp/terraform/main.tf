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

variable "TFC_GCP_PROVIDER_AUTH" {
  description = "Terraform Cloud will use dynamic credentials to authenticate to GCP"
  type        = string
}

variable "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL" {
  description = "The service account email address that Terraform Cloud will use to authenticate to Google Cloud"
  type        = string
}

variable "TFC_GCP_WORKLOAD_PROVIDER_NAME" {
  description = "The canonical name of the workload identity provider"
  type        = string
}

locals {
  default_environment = {
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
  global_custom_roles = var.global_custom_roles
}
