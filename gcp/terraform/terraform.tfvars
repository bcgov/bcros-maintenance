projects = {
  "bcr-businesses-sandbox" = {
    project_id = "a083gt-integration"

    service_accounts = {
      "test-tf-sa" = {
        roles = ["roles/storage.admin", "roles/logging.viewer"]
        description = "Service Account to test TF"
      }
    }
    custom_roles = {
      "testTFRole2" = {
        permissions = ["run.routes.list"]
        description  = "Custom role to test TF"
      }
    }
  }
}
