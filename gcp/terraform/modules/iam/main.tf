locals {
  merged_custom_roles = merge(
    var.global_custom_roles,
    var.env.environment_custom_roles,
    var.custom_roles
  )

  resource_iam_bindings = flatten([
    for sa_name, sa_attrs in var.service_accounts : [
      for role_entry in sa_attrs.resource_roles != null ? sa_attrs.resource_roles : [] : [
        for role in role_entry.roles : {
          sa_name  = sa_name
          role     = role
          resource = role_entry.resource
          resource_type = role_entry.resource_type
        }
      ]
    ]
  ])
}

resource "google_service_account" "sa" {
  for_each     = var.service_accounts
  project      = var.project_id
  account_id   = each.key
  display_name = each.key
  description  = each.value.description
}

resource "google_project_iam_member" "iam_members" {
  for_each = {
    for combo in flatten([
      for sa_name, sa_attrs in var.service_accounts : [
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

resource "google_project_iam_member" "external_iam_members" {
  for_each = {
    for combo in flatten([
      for sa_name, sa_attrs in var.service_accounts : [
        for role in sa_attrs.external_roles != null ? sa_attrs.external_roles : [] : [
          for single_role in role.roles : {
            sa_name    = sa_name
            role       = single_role
            project_id = role.project_id
          }
        ]
      ]
    ]) : "${combo.project_id}-${combo.sa_name}-${combo.role}" => combo
  }

  project = each.value.project_id
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

resource "google_cloud_run_service_iam_member" "resource_iam_members" {
  for_each = { for combo in local.resource_iam_bindings :
    "${combo.sa_name}-${combo.role}-${combo.resource}" => combo
    if combo.resource_type == "cloud_run"
  }

  service = each.value.resource
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.sa[each.value.sa_name].email}"
}

resource "google_storage_bucket_iam_member" "resource_iam_members" {
  for_each = {
    for combo in local.resource_iam_bindings :
    "${combo.sa_name}-${combo.role}-${combo.resource}" => combo
    if combo.resource_type == "storage_bucket"
  }

  bucket = each.value.resource
  role   = each.value.role
  member = "serviceAccount:${google_service_account.sa[each.value.sa_name].email}"
}

resource "google_secret_manager_secret_iam_member" "resource_iam_members" {
  for_each = {
    for combo in local.resource_iam_bindings :
    "${combo.sa_name}-${combo.role}-${combo.resource}" => combo
    if combo.resource_type == "secret_manager"
  }

  secret_id = each.value.resource
  role      = each.value.role
  member    = "serviceAccount:${google_service_account.sa[each.value.sa_name].email}"
}


resource "google_pubsub_topic_iam_member" "resource_iam_members" {
  for_each = {
    for combo in local.resource_iam_bindings :
    "${combo.sa_name}-${combo.role}-${combo.resource}" => combo
    if combo.resource_type == "pubsub_topic"
  }

  topic  = each.value.resource
  role   = each.value.role
  member = "serviceAccount:${google_service_account.sa[each.value.sa_name].email}"
}


resource "google_artifact_registry_repository_iam_member" "resource_iam_members" {
  for_each = {
    for combo in local.resource_iam_bindings :
    "${combo.sa_name}-${combo.role}-${combo.resource}" => combo
    if combo.resource_type == "artifact_registry"
  }

  repository = each.value.resource
  role       = each.value.role
  member     = "serviceAccount:${google_service_account.sa[each.value.sa_name].email}"
}


resource "google_service_account_iam_member" "resource_iam_members" {
  for_each = { for combo in local.resource_iam_bindings :
    "${combo.sa_name}-${combo.role}-${combo.resource}" => combo
    if combo.resource_type == "sa_iam_member"
  }

  service_account_id = each.value.resource
  role               = each.value.role
  member             = "serviceAccount:${google_service_account.sa[each.value.sa_name].email}"
}
