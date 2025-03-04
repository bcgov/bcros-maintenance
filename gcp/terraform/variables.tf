variable "GOOGLE_CREDENTIALS" {
  type        = string
  description = "Google Cloud service account credentials JSON"
  sensitive   = true
}

variable "region" {
    default = "northamerica-northeast1"
}


variable "projects" {
  type = map(object({
    project_id       = string
    env              = string
    service_accounts = optional(map(object({
      roles        = list(string)
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
