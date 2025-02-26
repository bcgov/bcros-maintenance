variable "project_id" {
  type = string
}

variable "service_accounts" {
  type = map(object({
    roles        = list(string)
    description  = optional(string, "Managed by Terraform")
  }))
}

variable "custom_roles" {
  type = map(object({
    title = string
    permissions  = list(string)
    description  = optional(string, "Custom role managed by Terraform")
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

variable "global_service_accounts" {
  type = map(object({
    roles        = list(string)
    description  = optional(string, "Managed by Terraform")
  }))
  default = {}
}

variable "env" {
  type = object({
    environment_service_accounts = optional(map(object({
      roles        = list(string)
      description  = optional(string, "Managed by Terraform")
    })), {})

    environment_custom_roles = optional(map(object({
      title = string
      permissions  = list(string)
      description  = optional(string, "Custom role managed by Terraform")
    })), {})
  })
  default = {}
}
