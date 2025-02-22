projects = {
  "bcr-businesses-sandbox" = {
    project_id = "a083gt-integration"
    env = "sandbox"

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

environments = {
  "sandbox" = {
    environment_service_accounts = {
      "sandbox-sa" = {
        roles       = ["roles/logging.viewer"]
        description = "Environment-specific service account"
      }
    }

    environment_custom_roles = {
      "sandboxRole" = {
        permissions = ["run.routes.list"]
        description = "Environment-specific custom role"
      }
    }
  }
}


global_service_accounts = {
  "global-sa" = {
    roles       = ["roles/storage.admin"]
    description = "global service account"
  }
}

global_custom_roles = {
  "globalRole" = {
    permissions = ["run.routes.list"]
    description = "global custom role"
  }
}
