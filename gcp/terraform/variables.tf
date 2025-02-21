variable "region" {
    default = "northamerica-northeast1"
}

variable "projects" {
  type = map(object({
    project_id       = string
    service_accounts = optional(map(object({
      roles        = list(string)
      description  = optional(string, "Managed by Terraform")
    })), {})

    custom_roles = optional(map(object({
      permissions  = list(string)
      description  = optional(string, "Custom role managed by Terraform")
    })), {})
  }))
}
