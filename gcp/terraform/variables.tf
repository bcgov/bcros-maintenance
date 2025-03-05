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

variable "region" {
    default = "northamerica-northeast1"
}


variable "projects" {
  type = map(object({
    project_id       = string
    env              = string
    service_accounts = optional(map(object({
      roles        = optional(list(string), [])
      external_roles = optional(list(object({
        roles        = list(string)
        project_id = string
      })), [])
      resource_roles = optional(list(object({
        resource = string
        roles    = list(string)
        resource_type = string
      })), [])
      description  = optional(string, "Managed by Terraform")
    })), {})

    custom_roles = optional(map(object({
      title = string
      permissions  = list(string)
      description  = optional(string, "Custom role managed by Terraform")
    })), {})
  }))
}

variable "global_custom_roles" {
  type = map(object({
    title = string
    permissions  = list(string)
    description  = optional(string, "Custom role managed by Terraform")
  }))
  default = {}
}

variable "environments" {
  type = map(object({
    environment_custom_roles = optional(map(object({
      title = string
      permissions  = list(string)
      description  = optional(string, "Custom role managed by Terraform")
    })), {})
  }))
  default = {}
}
