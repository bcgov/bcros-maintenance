resource "google_service_account" "sa" {
  for_each     = var.service_accounts
  project      = var.project_id
  account_id   = each.key
  display_name = "Service Account: ${each.key}"
  description  = each.value.description
}

resource "google_project_iam_binding" "iam_roles" {
  for_each = {
    for combo in flatten([
      for sa_name, sa_attrs in var.service_accounts : [
        for role in sa_attrs.roles : {
          sa_name = sa_name
          role    = role
        }
      ]
    ]) : "${combo.sa_name}-${combo.role}" => combo
  }

  project = var.project_id
  role    = each.value.role

  members = [
    "serviceAccount:${google_service_account.sa[each.value.sa_name].email}"
  ]
}


resource "google_project_iam_custom_role" "custom_roles" {
  for_each    = var.custom_roles
  project     = var.project_id
  role_id     = split("/", each.key)[1]
  title       = each.key
  permissions = each.value.permissions
  description = each.value.description
}
