locals {
  merged_service_accounts = merge(
    var.global_service_accounts,
    var.env.environment_service_accounts,
    var.service_accounts
  )
  merged_custom_roles = merge(
    var.global_custom_roles,
    var.env.environment_custom_roles,
    var.custom_roles
  )
}

resource "google_service_account" "sa" {
  for_each     = local.merged_service_accounts
  project      = var.project_id
  account_id   = each.key
  display_name = each.key
  description  = each.value.description
}

resource "google_project_iam_member" "iam_members" {
  for_each = {
    for combo in flatten([
      for sa_name, sa_attrs in local.merged_service_accounts : [
        for role in sa_attrs.roles != null ? sa_attrs.roles : [] : {
          sa_name = sa_name
          role    = role
        }
      ]
    ]) : "${var.project_id}-${combo.sa_name}-${combo.role}" => combo
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.sa[each.value.sa_name].email}"
}

resource "google_project_iam_custom_role" "custom_roles" {
  for_each    = local.merged_custom_roles
  project     = var.project_id
  role_id     = each.key
  title       = each.value.title
  permissions = each.value.permissions
  description = each.value.description
}
