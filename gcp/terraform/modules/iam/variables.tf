variable "project_id" {
  type = string
}

variable "env" {
  type        = string
  description = "The environment (e.g., sandbox, dev, prod) to which the resources belong."
}

variable "service_accounts" {
  type = map(object({
    roles        = list(string)
    description  = optional(string, "Managed by Terraform")
  }))
}

variable "custom_roles" {
  type = map(object({
    permissions  = list(string)
    description  = optional(string, "Custom role managed by Terraform")
  }))
}

variable "global_custom_roles" {
  type = map(object({
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

variable "environments" {
  type = map(object({
    environment_service_accounts = optional(map(object({
      roles        = list(string)
      description  = optional(string, "Managed by Terraform")
    })), {})

    environment_custom_roles = optional(map(object({
      permissions  = list(string)
      description  = optional(string, "Custom role managed by Terraform")
    })), {})
  }))
  default = {}
}
