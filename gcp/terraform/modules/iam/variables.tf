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
    permissions  = list(string)
    description  = optional(string, "Custom role managed by Terraform")
  }))
}
