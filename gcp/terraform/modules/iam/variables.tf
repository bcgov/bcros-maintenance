variable "project_id" {
  type = string
}

variable "service_accounts" {
  type = map(object({
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

variable "env" {
  type = object({
    environment_custom_roles = optional(map(object({
      title = string
      permissions  = list(string)
      description  = optional(string, "Custom role managed by Terraform")
    })), {})
  })
  default = {}
}
