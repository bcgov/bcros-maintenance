projects = {
  "analytics-int-prod" = {
    project_id = "mvnjri-prod"
    env = "prod"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/mvnjri-prod/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/mvnjri-prod/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/mvnjri-prod/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      jupyter-dashboard-int-prod = {
        roles       = ["roles/iam.serviceAccountUser"]
        description = ""
      },
      sa-staff-warehouse-mvnjri = {
        roles       = ["roles/cloudsql.client", "roles/cloudsql.instanceUser", "roles/cloudsql.viewer"]
        description = "Service Account for enabling staff connecton to data warehouse"
      },
      fin-warehouse-bucket-writer = {
        roles       = ["roles/iam.serviceAccountUser", "roles/storage.objectCreator", "roles/storage.objectViewer"]
        description = ""
        resource_roles = [
          {
            resource = "projects/mvnjri-prod/serviceAccounts/fin-warehouse-bucket-writer@mvnjri-prod.iam.gserviceaccount.com"
            roles    = ["roles/iam.serviceAccountUser"]
            resource_type = "sa_iam_member"
          }
        ]
      },
      github-actions = {
        roles       = ["roles/iam.serviceAccountUser", "roles/serviceusage.apiKeysViewer", "roles/storage.objectAdmin"]
        description = " Data syncing between bcgov-registries/analytics sql files and data warehouse bucket"
      },
      sa-analytics-fin-warehouse = {
        roles       = ["roles/cloudsql.client", "roles/cloudsql.viewer"]
        description = "fin_warehouse database access"
      },
      client-sql-proxy-service-accnt = {
        roles       = ["roles/cloudsql.admin", "roles/cloudsql.client", "roles/cloudsql.editor"]
        description = ""
      }
    }
  }
  "common-prod" = {
    project_id = "c4hnrd-prod"
    env = "prod"
    service_accounts = {
      sa-pubsub = {
        roles       = ["projects/c4hnrd-prod/roles/rolequeue", "roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/run.invoker"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/c4hnrd-prod/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/c4hnrd-prod/roles/roleapi", "roles/cloudsql.instanceUser", "roles/run.serviceAgent"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/c4hnrd-prod/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      doc-prod-sa = {
        description = "Document Services Service Account"
        resource_roles = [
          {
            resource = "docs_ppr_prod"
            roles    = ["roles/storage.admin"]
            resource_type = "storage_bucket"
          },
          {
            resource = "docs_nr_prod"
            roles    = ["roles/storage.admin"]
            resource_type = "storage_bucket"
          },
          {
            resource = "docs_mhr_prod"
            roles    = ["roles/storage.admin"]
            resource_type = "storage_bucket"
          },
          {
            resource = "docs_business_prod"
            roles    = ["roles/storage.admin"]
            resource_type = "storage_bucket"
          }
        ]
      }
    }
  }
  "connect-prod" = {
    project_id = "gtksf3-prod"
    env = "prod"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/run.invoker"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/gtksf3-prod/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/gtksf3-prod/roles/roleapi", "roles/cloudsql.client"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/gtksf3-prod/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      auth-db-bucket-writer = {
        roles       = ["roles/iam.serviceAccountUser", "roles/storage.objectAdmin", "roles/storage.objectCreator", "roles/storage.objectViewer"]
        description = "Service Account for syncing anon extension masking rule files to auth-db dump bucket"
      },
      sa-auth-db-standby = {
        roles       = ["roles/cloudsql.client", "roles/cloudsql.viewer"]
        description = "Service account used to backup auth db in OpenShift Gold Cluster, as part of disaster recovery plan."
      }
    }
  }
  "bor-prod" = {
    project_id = "yfjq17-prod"
    env = "prod"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/yfjq17-prod/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/yfjq17-prod/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/yfjq17-prod/roles/rolequeue"]
        description = "Service Account for running queue services"
      }
    }
  }
  "bcr-businesses-prod" = {
    project_id = "a083gt-prod"
    env = "prod"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/run.invoker"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/a083gt-prod/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/a083gt-prod/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/a083gt-prod/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      sa-lear-db-standby = {
        roles       = ["roles/cloudsql.client", "roles/cloudsql.viewer"]
        description = "Service account used to backup business db in OpenShift Gold Cluster, as part of disaster recovery plan."
      }
    }
  }
  "business-number-hub-prod" = {
    project_id = "keee67-prod"
    env = "prod"
    service_accounts = {
      bn-tasks-run-invoker-prod = {
        roles       = ["roles/editor", "roles/iam.serviceAccountUser"]
        description = ""
      },
      bn-batch-processor-prod = {
        roles       = ["roles/cloudtasks.admin", "roles/editor"]
        description = ""
      },
      sa-bni-file-upload-prod = {
        roles       = ["roles/storage.objectCreator"]
        description = "Service Account to upload raw batch files to the BNI storage bucket"
      },
      pubsub-cloud-run-invoker-prod = {
      description = ""
      resource_roles = [
          {
            resource = "projects/keee67-prod/locations/northamerica-northeast1/services/bn-batch-parser"
            roles    = ["roles/run.invoker"]
            resource_type = "cloud_run"
          }
        ]
      }
    }
  }
  "ppr-prod" = {
    project_id = "eogruh-prod"
    env = "prod"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/eogruh-prod/roles/rolejob"]
        description = "Service Account for running job services"
      }
      sa-api = {
        roles       = ["projects/eogruh-prod/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/eogruh-prod/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      ppr-prod-sa = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.admin", "roles/storage.admin"]
        description = "Default service account for ppr cloud services"
        resource_roles = [
            {
              resource = "projects/eogruh-prod/locations/northamerica-northeast1/services/gotenberg"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/c4hnrd-prod/topics/doc-api-app-create-record"
              roles    = ["roles/pubsub.publisher"]
              resource_type = "pubsub_topic"
            }
          ]
      },
      sa-ppr-document-storage = {
        roles       = ["projects/eogruh-prod/roles/CustomStorageAdmin", "roles/iam.serviceAccountTokenCreator"]
        description = "Default service account for ppr cloud services"
      },
      document-pubsub-invoker = {
        roles       = ["roles/pubsub.admin"]
        description = ""
        resource_roles = [
            {
              resource = "projects/eogruh-prod/locations/northamerica-northeast1/services/document-delivery-service"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            }
          ]
      },
      sa-analytics-status-update-not = {
        roles       = ["roles/cloudsql.client", "roles/cloudsql.viewer"]
        description = ""
      },
      bc-ppr-client-direct-docs-prod = {
        roles       = ["projects/eogruh-prod/roles/CustomStorageAdmin", "roles/iam.serviceAccountTokenCreator"]
        description = ""
      }
    }
  }
  "search-prod" = {
    project_id = "k973yf-prod"
    env = "prod"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/k973yf-prod/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/k973yf-prod/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/k973yf-prod/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      gha-wif = {
        roles       = ["roles/compute.admin"]
        description = "Service account used by WIF POC"
        external_roles = [{
          roles        = ["roles/compute.imageUser"]
          project_id  = "k973yf-dev"
        }]
        resource_roles = [
          {
            resource = "projects/k973yf-prod/serviceAccounts/357033077029-compute@developer.gserviceaccount.com"
            roles    = ["roles/iam.serviceAccountUser"]
            resource_type = "sa_iam_member"
          }
        ]
      }
    }
  }
  "web-presence-prod" = {
    project_id = "yfthig-prod"
    env = "prod"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/yfthig-prod/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/yfthig-prod/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/yfthig-prod/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      github-actions = {
        roles       = ["roles/cloudbuild.builds.editor", "roles/firebaseauth.admin", "roles/firebasehosting.admin", "roles/run.viewer", "roles/serviceusage.apiKeysViewer", "roles/serviceusage.serviceUsageConsumer", "roles/storage.admin"]
        description = "A service account with permission to deploy to Firebase Hosting for the GitHub repository"
      }
    }
  }
  "strr-prod" = {
    project_id = "bcrbk9-prod"
    env = "prod"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/bigquery.dataOwner", "roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/run.invoker"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/bcrbk9-prod/roles/rolejob", "roles/pubsub.publisher"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/bcrbk9-prod/roles/roleapi", "roles/pubsub.publisher", "roles/storage.admin", "roles/storage.objectCreator"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/bcrbk9-prod/roles/rolequeue"]
        description = "Service Account for running queue services"
      }
    }
  }
  "analytics-ext-prod" = {
    project_id = "sbgmug-prod"
    env = "prod"
  }
  "api-gateway-prod" = {
    project_id = "okagqp-prod"
    env = "prod"
    service_accounts = {
      apigee-prod-sa = {
        roles       = ["roles/apigee.developerAdmin", "roles/bigquery.dataEditor", "roles/bigquery.jobUser", "roles/iam.serviceAccountTokenCreator", "roles/logging.admin", "roles/storage.admin"]
        description = "Service account for the BC Registries Apigee prod environment."
        external_roles = [{
          roles        = ["roles/cloudfunctions.invoker"]
          project_id  = "mvnjri-prod"
        }]
        resource_roles = [
            {
              resource = "projects/yfjq17-prod/locations/northamerica-northeast1/services/pam-request-grant-create-bor"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/keee67-prod/locations/northamerica-northeast1/services/pam-request-grant-create-vans-db-prod"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/keee67-prod/locations/northamerica-northeast1/services/pam-request-grant-create-bni-hub"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/gtksf3-prod/locations/northamerica-northeast1/services/pam-request-grant-create-auth-db"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/c4hnrd-prod/locations/northamerica-northeast1/services/pam-request-grant-create-docs"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/c4hnrd-prod/locations/northamerica-northeast1/services/pam-request-grant-create-notify"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/a083gt-prod/locations/northamerica-northeast1/services/pam-request-grant-create-legal-entities"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/a083gt-prod/locations/northamerica-northeast1/services/pam-request-grant-create-business-ar"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/k973yf-prod/locations/northamerica-northeast1/services/pam-request-grant-create-search"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/eogruh-prod/locations/northamerica-northeast1/services/pam-request-grant-create-ppr"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/mvnjri-prod/locations/northamerica-northeast1/services/pam-request-grant-create"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            }
          ]
      }
    }
  }
  "common-test" = {
    project_id = "c4hnrd-test"
    env = "test"
    service_accounts = {
      sa-pubsub = {
        roles       = ["projects/c4hnrd-test/roles/rolequeue", "roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/run.invoker"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/c4hnrd-test/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/c4hnrd-test/roles/roleapi", "roles/cloudsql.instanceUser", "roles/run.serviceAgent"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/c4hnrd-test/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      doc-test-sa = {
        description = "Document Services Service Account"
        resource_roles = [
          {
            resource = "docs_ppr_test"
            roles    = ["roles/storage.admin"]
            resource_type = "storage_bucket"
          },
          {
            resource = "docs_nr_test"
            roles    = ["roles/storage.admin"]
            resource_type = "storage_bucket"
          },
          {
            resource = "docs_mhr_test"
            roles    = ["roles/storage.admin"]
            resource_type = "storage_bucket"
          },
          {
            resource = "docs_business_test"
            roles    = ["roles/storage.admin"]
            resource_type = "storage_bucket"
          }
        ]
      }
    }
  }
  "connect-test" = {
    project_id = "gtksf3-test"
    env = "test"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/gtksf3-test/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/gtksf3-test/roles/roleapi", "roles/cloudsql.client"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/gtksf3-test/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      sa-auth-db-standby = {
        roles       = ["roles/cloudsql.client", "roles/cloudsql.viewer"]
        description = "Service account used to backup auth db in OpenShift Gold Cluster, as part of disaster recovery plan."
      }
    }
  }
  "bor-test" = {
    project_id = "yfjq17-test"
    env = "test"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/yfjq17-test/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/yfjq17-test/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/yfjq17-test/roles/rolequeue"]
        description = "Service Account for running queue services"
      }
    }
  }
  "bcr-businesses-test" = {
    project_id = "a083gt-test"
    env = "test"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/run.invoker"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/a083gt-test/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/a083gt-test/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/a083gt-test/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      sa-bni-file-upload-test = {
        roles       = ["roles/storage.objectCreator"]
        description = "Service Account to upload raw batch files to the BNI storage bucket"
      },
      business-ar-job-proc-paid-test = {
        roles       = ["roles/run.invoker"]
        description = "submit AR back to the SOR"
      },
      sa-lear-db-standby = {
        roles       = ["roles/cloudsql.client", "roles/cloudsql.viewer"]
        description = ""
      }

    }
  }
  "business-number-hub-test" = {
    project_id = "keee67-test"
    env = "test"
    service_accounts = {
      bn-batch-processor-test = {
        roles       = ["roles/cloudtasks.admin", "roles/editor", "roles/run.invoker", "roles/storage.admin"]
        description = ""
      },
      bn-tasks-run-invoker-test = {
        roles       = ["roles/editor", "roles/iam.serviceAccountUser", "roles/storage.objectCreator"]
        description = ""
        resource_roles = [
          {
            resource = "projects/keee67-test/serviceAccounts/bn-tasks-run-invoker-test@keee67-test.iam.gserviceaccount.com"
            roles    = ["roles/iam.serviceAccountAdmin"]
            resource_type = "sa_iam_member"
          }
        ]
      },
      sa-bni-file-upload-test = {
        roles       = ["roles/storage.objectCreator"]
        description = "Service Account to upload raw batch files to the BNI storage bucket"
      },
      pubsub-cloud-run-invoker-test = {
      description = ""
      resource_roles = [
          {
            resource = "projects/keee67-test/locations/northamerica-northeast1/services/bn-batch-parser"
            roles    = ["roles/run.invoker"]
            resource_type = "cloud_run"
          }
        ]
      }
    }
  }
  "ppr-test" = {
    project_id = "eogruh-test"
    env = "test"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/eogruh-test/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/eogruh-test/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/eogruh-test/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      ppr-temp-verification-sa = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.admin"]
        description = ""
      },
      sa-ppr-documents-test = {
        roles       = ["projects/eogruh-test/roles/ppr_document_storage_test", "roles/cloudsql.client", "roles/iam.serviceAccountTokenCreator"]
        description = ""
        resource_roles = [
          {
            resource = "ppr_documents_test"
            roles    = ["projects/eogruh-test/roles/ppr_document_storage_test"]
            resource_type = "storage_bucket"
          }
        ]
      },
      notify-identity = {
        roles       = ["roles/cloudsql.client"]
        description = ""
      },
      ppr-test-sa = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.admin", "roles/storage.admin"]
        description = "Default service account for ppr cloud services"
        resource_roles = [
            {
              resource = "projects/eogruh-test/locations/northamerica-northeast1/services/gotenberg"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            },
            {
              resource = "projects/c4hnrd-test/topics/doc-api-app-create-record"
              roles    = ["roles/pubsub.publisher"]
              resource_type = "pubsub_topic"
            }
          ]
      }
    }
  }
  "search-test" = {
    project_id = "k973yf-test"
    env = "test"
    service_accounts = {
      gha-wif = {
        roles       = ["roles/compute.admin"]
        description = "Service account used by WIF POC"
        external_roles = [{
          roles        = ["roles/compute.imageUser"]
          project_id  = "k973yf-dev"
        }]
        resource_roles = [
            {
              resource = "projects/k973yf-test/serviceAccounts/107836257140-compute@developer.gserviceaccount.com"
              roles    = ["roles/iam.serviceAccountUser"]
              resource_type = "sa_iam_member"
            }
          ]
      }
    }
  }
  "web-presence-test" = {
    project_id = "yfthig-test"
    env = "test"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/yfthig-test/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/yfthig-test/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/yfthig-test/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      github-action-416185190 = {
        roles       = ["roles/cloudbuild.builds.editor", "roles/firebaseauth.admin", "roles/firebasehosting.admin", "roles/run.viewer", "roles/serviceusage.apiKeysViewer", "roles/serviceusage.serviceUsageConsumer", "roles/storage.admin"]
        description = "A service account with permission to deploy to Firebase Hosting for the GitHub repository thorwolpert/fh-test"
      },
      sa-cdcloudrun = {
        roles       = ["projects/yfthig-test/roles/rolecdcloudrun"]
        description = "Service Account for running cdcloudrun services"
      }
    }
  }
  "strr-test" = {
    project_id = "bcrbk9-test"
    env = "test"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/run.invoker"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/bcrbk9-test/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/bcrbk9-test/roles/roleapi", "roles/pubsub.publisher", "roles/storage.admin", "roles/storage.objectCreator"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/bcrbk9-test/roles/rolequeue"]
        description = "Service Account for running queue services"
      }
    }
  }
  "analytics-ext-test" = {
    project_id = "sbgmug-test"
    env = "test"
  }
  "api-gateway-test" = {
    project_id = "okagqp-test"
    env = "test"
    service_accounts = {
      apigee-test-sa = {
        roles       = ["roles/apigee.apiAdminV2", "roles/apigee.developerAdmin", "roles/logging.admin", "roles/logging.serviceAgent", "roles/storage.admin"]
        description = "Service account for apigee gateway integration including logging"
      }
    }
  }
  "analytics-int-dev" = {
    project_id = "mvnjri-dev"
    env = "dev"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/mvnjri-dev/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/mvnjri-dev/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/mvnjri-dev/roles/rolequeue"]
        description = "Service Account for running queue services"
      }
    }
  }
  "common-dev" = {
    project_id = "c4hnrd-dev"
    env = "dev"
    service_accounts = {
      sa-pubsub = {
        roles       = ["projects/c4hnrd-dev/roles/rolequeue", "roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/run.invoker"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/c4hnrd-dev/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/c4hnrd-dev/roles/roleapi", "roles/cloudsql.instanceUser", "roles/serverless.serviceAgent"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/c4hnrd-dev/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      open-shift-artifact-registry = {
        roles       = ["roles/artifactregistry.serviceAgent", "roles/cloudbuild.builds.builder", "roles/containerregistry.ServiceAgent"]
        description = ""
      },
      documentai-workflow-service-ac = {
        roles       = ["roles/composer.environmentAndStorageObjectViewer", "roles/documentai.apiUser", "roles/eventarc.eventReceiver", "roles/logging.logWriter", "roles/serviceusage.serviceUsageConsumer", "roles/storage.objectUser", "roles/storagetransfer.user", "roles/workflows.invoker"]
        description = ""
        resource_roles = [
          { resource = "projects/c4hnrd-dev/locations/asia/repositories/asia.gcr.io"
            roles    = ["roles/artifactregistry.repoAdmin"]
            resource_type = "artifact_registry"
          },
          { resource = "projects/c4hnrd-dev/locations/europe/repositories/eu.gcr.io"
            roles    = ["roles/artifactregistry.repoAdmin"]
            resource_type = "artifact_registry"
          },
          { resource = "projects/c4hnrd-dev/locations/us/repositories/gcr.io"
            roles    = ["roles/artifactregistry.repoAdmin"]
            resource_type = "artifact_registry"
          },
          { resource = "projects/c4hnrd-dev/locations/us/repositories/us.gcr.io"
            roles    = ["roles/artifactregistry.repoAdmin"]
            resource_type = "artifact_registry"
          }
        ]
      },
      doc-dev-sa = {
        roles       = ["roles/artifactregistry.serviceAgent", "roles/compute.admin", "roles/storage.admin"]
        description = "Document Services Service Account"
        resource_roles = [
          { resource = "projects/c4hnrd-dev/locations/asia/repositories/asia.gcr.io"
            roles    = ["roles/artifactregistry.repoAdmin"]
            resource_type = "artifact_registry"
          },
          { resource = "projects/c4hnrd-dev/locations/europe/repositories/eu.gcr.io"
            roles    = ["roles/artifactregistry.repoAdmin"]
            resource_type = "artifact_registry"
          },
          { resource = "projects/c4hnrd-dev/locations/us/repositories/gcr.io"
            roles    = ["roles/artifactregistry.repoAdmin"]
            resource_type = "artifact_registry"
          },
          { resource = "projects/c4hnrd-dev/locations/us/repositories/us.gcr.io"
            roles    = ["roles/artifactregistry.repoAdmin"]
            resource_type = "artifact_registry"
          }
        ]
      },
      synthetic-monitoring = {
        roles       = ["roles/cloudfunctions.developer", "roles/logging.logWriter", "roles/monitoring.editor", "roles/run.admin", "roles/run.serviceAgent", "roles/secretmanager.secretAccessor", "roles/secretmanager.viewer"]
        description = "POC for synthetic monitoring"
        resource_roles = [
          { resource = "registries-synthetic-monitor"
            roles    = ["roles/storage.legacyBucketReader", "roles/storage.objectAdmin"]
            resource_type = "storage_bucket"
          },
          { resource = "projects/366678529892/secrets/PWDIDIR"
            roles    = ["roles/secretmanager.secretAccessor"]
            resource_type = "secret_manager"
          },
          { resource = "projects/366678529892/secrets/USERNAMEIDIR"
            roles    = ["roles/secretmanager.secretAccessor"]
            resource_type = "secret_manager"
          },
          { resource = "projects/366678529892/secrets/PWDSCBC"
            roles    = ["roles/secretmanager.secretAccessor"]
            resource_type = "secret_manager"
          },
          { resource = "projects/366678529892/secrets/USERNAMESCBC"
            roles    = ["roles/secretmanager.secretAccessor"]
            resource_type = "secret_manager"
          }
        ]
      }
    }
  }
  "connect-dev" = {
    project_id = "gtksf3-dev"
    env = "dev"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
        resource_roles = [
            {
              resource = "projects/a083gt-dev/locations/northamerica-northeast1/services/namex-pay-dev"
              roles    = ["roles/run.invoker"]
              resource_type = "cloud_run"
            }
          ]
      },
      sa-job = {
        roles       = ["projects/gtksf3-dev/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/gtksf3-dev/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/gtksf3-dev/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      pay-test = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = ""
      },
      pay-pubsub-sa = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for handling pay pusub subscriptions"
        external_roles = [{
          roles       = ["roles/iam.serviceAccountTokenCreator", "roles/run.invoker"]
          project_id  = "bcrbk9-dev"
        },
        {
          roles        = ["roles/iam.serviceAccountTokenCreator", "roles/run.invoker"]
          project_id  = "a083gt-dev"
        }
      ]

      },
      sa-auth-db-standby-759 = {
        roles       = ["roles/cloudsql.client", "roles/cloudsql.viewer"]
        description = "Service account used to backup auth db in OpenShift Gold Cluster, as part of disaster recovery plan."
      },
      sre-role-testing-account = {
        roles       = ["projects/gtksf3-dev/roles/SRE"]
        description = ""
      }
    }
  }
  "bor-dev" = {
    project_id = "yfjq17-dev"
    env = "dev"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/yfjq17-dev/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/yfjq17-dev/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/yfjq17-dev/roles/rolequeue"]
        description = "Service Account for running queue services"
      }
    }
  }
  "bcr-businesses-dev" = {
    project_id = "a083gt-dev"
    env = "dev"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/run.invoker"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/a083gt-dev/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/a083gt-dev/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/a083gt-dev/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      business-ar-job-process-paid = {
        roles       = ["roles/run.invoker"]
        description = ""
      },
      sa-lear-db-standby = {
        roles       = ["roles/cloudsql.client", "roles/cloudsql.viewer"]
        description = ""
      },
      sa-bni-file-upload-dev = {
        roles       = ["roles/storage.objectCreator"]
        description = "Service Account to upload raw batch files to the BNI storage bucket"
      },
      business-pubsub-sa = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = ""
      }
    }
  }
  "business-number-hub-dev" = {
    project_id = "keee67-dev"
    env = "dev"
    service_accounts = {
      bn-tasks-cloud-run-invoker = {
        roles       = ["roles/cloudtasks.enqueuer", "roles/iam.serviceAccountUser", "roles/run.invoker"]
        description = "BN Tasks Cloud Run Invoker"
      },
      sa-bni-file-upload-dev = {
        roles       = ["roles/storage.objectCreator"]
        description = "Service Account to upload raw batch files to the BNI storage bucket"
      },
      pubsub-cloud-run-invoker = {
      description = ""
      resource_roles = [
          {
            resource = "projects/keee67-dev/locations/northamerica-northeast1/services/bn-batch-parser"
            roles    = ["roles/run.invoker"]
            resource_type = "cloud_run"
          }
        ]
      }
    }
  }
  "ppr-dev" = {
    project_id = "eogruh-dev"
    env = "dev"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-api = {
        roles       = ["projects/eogruh-dev/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/eogruh-dev/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      sa-ppr-db-standby = {
        roles       = ["roles/cloudsql.client", "roles/cloudsql.viewer"]
        description = ""
      },
      ppr-dev-sa = {
        roles       = ["roles/containerregistry.ServiceAgent", "roles/iam.serviceAccountTokenCreator", "roles/pubsub.admin", "roles/pubsub.serviceAgent", "roles/storage.admin", "roles/storage.objectCreator"]
        description = "Default service account for ppr cloud services"
        resource_roles = [
          { resource = "eogruh-dev_cloudbuild"
            roles    = ["roles/storage.legacyBucketWriter"]
            resource_type = "storage_bucket"
          },
          { resource = "projects/c4hnrd-dev/topics/doc-api-app-create-record"
            roles    = ["roles/pubsub.publisher"]
            resource_type = "pubsub_topic"
          },
          { resource = "projects/eogruh-dev/locations/us/repositories/gcr.io"
            roles    = ["roles/artifactregistry.repoAdmin"]
            resource_type = "artifact_registry"
          }
        ]
      }
    }
  }
  "search-dev" = {
    project_id = "k973yf-dev"
    env = "dev"
    service_accounts = {
      gha-wif = {
        roles       = ["roles/compute.admin", "roles/storage.objectAdmin"]
        description = "Service account used by WIF POC"
        resource_roles = [
          {
            resource = "projects/k973yf-dev/serviceAccounts/952634948388-compute@developer.gserviceaccount.com"
            roles    = ["roles/iam.serviceAccountUser"]
            resource_type = "sa_iam_member"
          }
        ]
      }
    }
  }
  "web-presence-dev" = {
    project_id = "yfthig-dev"
    env = "dev"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/yfthig-dev/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/yfthig-dev/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/yfthig-dev/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      apigee-dev-sa = {
        roles       = ["roles/logging.admin", "roles/storage.admin"]
        description = "Service account for BC Registries Apigee dev environment."
      },
      github-action-467311281 = {
        roles       = ["roles/cloudbuild.builds.editor", "roles/firebaseauth.admin", "roles/firebasehosting.admin", "roles/run.viewer", "roles/serviceusage.apiKeysViewer", "roles/serviceusage.serviceUsageConsumer", "roles/storage.admin"]
        description = "A service account with permission to deploy to Firebase Hosting for the GitHub repository thorwolpert/bcregistry"
      }
    }
  }
  "strr-dev" = {
    project_id = "bcrbk9-dev"
    env = "dev"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/run.invoker"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/bcrbk9-dev/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/bcrbk9-dev/roles/roleapi", "roles/pubsub.publisher", "roles/storage.admin", "roles/storage.objectCreator"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/bcrbk9-dev/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      sa-eventarc = {
        roles       = ["roles/eventarc.eventReceiver", "roles/run.invoker"]
        description = "Service Account for running queue services"
      },
      test-notebook-dev = {
        roles       = ["roles/cloudsql.client", "roles/cloudsql.instanceUser", "roles/cloudsql.schemaViewer"]
        description = "used with the test services"
      },
      client-sql-proxy-service-accnt = {
        roles       = ["roles/cloudsql.admin", "roles/cloudsql.client"]
        description = ""
      },

    }
  }
  "analytics-ext-dev" = {
    project_id = "sbgmug-dev"
    env = "dev"
  }
  "api-gateway-dev" = {
    project_id = "okagqp-dev"
    env = "dev"
    service_accounts = {
      apigee-dev-sa = {
        roles       = ["roles/logging.admin", "roles/storage.admin"]
        description = "Service accont for apigee gateway integration including logging."
      }
    }
  }
  "common-sandbox" = {
    project_id = "c4hnrd-sandbox"
    env = "sandbox"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/c4hnrd-sandbox/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/c4hnrd-sandbox/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/c4hnrd-sandbox/roles/rolequeue"]
        description = "Service Account for running queue services"
      }
    }
  }
  "connect-sandbox" = {
    project_id = "gtksf3-tools"
    env = "sandbox"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/gtksf3-tools/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/gtksf3-tools/roles/roleapi", "roles/cloudsql.client"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/gtksf3-tools/roles/rolequeue"]
        description = "Service Account for running queue services"
      }
    }
  }
  "bor-sandbox" = {
    project_id = "yfjq17-tools"
    env = "sandbox"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/yfjq17-tools/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/yfjq17-tools/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/yfjq17-tools/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      btr-cd = {
        roles       = ["roles/editor"]
        description = ""
      }
    }
  }
  "bcr-businesses-tools" = {
    project_id = "a083gt-tools"
    env = "sandbox"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/a083gt-tools/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/a083gt-tools/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/a083gt-tools/roles/rolequeue"]
        description = "Service Account for running queue services"
      }
    }
  }
  "business-number-hub-sandbox" = {
    project_id = "keee67-tools"
    env = "sandbox"
  }
  "ppr-sandbox" = {
    project_id = "eogruh-sandbox"
    env = "sandbox"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/eogruh-sandbox/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/eogruh-sandbox/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/eogruh-sandbox/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      ppr-sandbox-sa = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.admin", "roles/storage.admin"]
        description = "Default service account for ppr cloud services"
      }
    }
  }
  "search-sandbox" = {
    project_id = "k973yf--tools"
    env = "sandbox"
  }
  "web-presence-sandbox" = {
    project_id = "yfthig-tools"
    env = "sandbox"
    service_accounts = {
      sa-job = {
        roles       = ["projects/yfthig-tools/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/yfthig-tools/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-cdcloudrun = {
        roles       = ["projects/yfthig-tools/roles/rolecdcloudrun"]
        description = "Service Account for running cdcloudrun services"
      }
    }
  }
  "strr-sandbox" = {
    project_id = "bcrbk9-tools"
    env = "sandbox"
    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/bcrbk9-tools/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/bcrbk9-tools/roles/roleapi", "roles/storage.admin"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/bcrbk9-tools/roles/rolequeue"]
        description = "Service Account for running queue services"
      }
    }
  }
  "analytics-ext-sandbox" = {
    project_id = "sbgmug-sandbox"
    env = "sandbox"
  }
  "api-gateway-sandbox" = {
    project_id = "okagqp-sandbox"
    env = "sandbox"
    service_accounts = {
      apigee-sandbox-sa = {
        roles       = ["roles/apigee.developerAdmin", "roles/bigquery.dataEditor", "roles/bigquery.jobUser", "roles/iam.serviceAccountTokenCreator", "roles/logging.admin", "roles/storage.admin"]
        description = "Service account for the BC Registries Apigee sandbox/uat environment."
      }
    }
  }
  "bcr-businesses-sandbox" = {
    project_id = "a083gt-integration"
    env = "sandbox"

    service_accounts = {
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/run.invoker"]
        description = "Service Account for running pubsub services"
      },
      sa-job = {
        roles       = ["projects/a083gt-integration/roles/rolejob"]
        description = "Service Account for running job services"
      },
      sa-api = {
        roles       = ["projects/a083gt-integration/roles/roleapi"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/a083gt-integration/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      sa-cdcloudrun = {
        roles       = ["projects/a083gt-integration/roles/rolecdcloudrun"]
        description = "Service Account for running cdcloudrun services"
      }
    }
  }
  "common-tools" = {
    project_id = "c4hnrd-tools"
    env = "tools"
    custom_roles = {
      cdcloudbuild = {
        title = "CD Cloud Build"
        description = "Role for cloud deploy CD flow."
        permissions = [
          "artifactregistry.tags.list",
          "artifactregistry.tags.update",
          "resourcemanager.projects.get",
          "iam.serviceAccounts.actAs",
          "secretmanager.versions.access",
          "cloudbuild.builds.create",
          "cloudbuild.builds.get",
          "storage.buckets.get",
          "storage.buckets.list",
          "storage.buckets.create",
          "storage.buckets.delete",
          "storage.objects.create",
          "storage.objects.get",
          "storage.objects.delete",
          "storage.objects.list",
          "artifactregistry.repositories.downloadArtifacts",
          "artifactregistry.repositories.get",
          "artifactregistry.repositories.uploadArtifacts",
          "artifactregistry.tags.create",
          "artifactregistry.tags.delete",
          "artifactregistry.tags.get",
          "serviceusage.services.get"
        ]
      },
      cdclouddeploy = {
        title = "CD Cloud Deploy"
        description = "Role for cloud deploy CD flow."
        permissions = [
          "resourcemanager.projects.get",
          "cloudbuild.builds.create",
          "cloudbuild.builds.get",
          "cloudbuild.builds.list",
          "iam.serviceAccounts.actAs",
          "pubsub.topics.publish",
          "serviceusage.services.use",
          "storage.buckets.create",
          "storage.buckets.get",
          "storage.buckets.delete",
          "clouddeploy.config.get",
          "clouddeploy.deliveryPipelines.create",
          "clouddeploy.deliveryPipelines.get",
          "clouddeploy.deliveryPipelines.list",
          "clouddeploy.deliveryPipelines.update",
          "clouddeploy.jobRuns.get",
          "clouddeploy.jobRuns.list",
          "clouddeploy.jobRuns.terminate",
          "clouddeploy.locations.get",
          "clouddeploy.locations.list",
          "clouddeploy.operations.cancel",
          "clouddeploy.operations.get",
          "clouddeploy.operations.list",
          "clouddeploy.releases.abandon",
          "clouddeploy.releases.create",
          "clouddeploy.releases.get",
          "clouddeploy.releases.list",
          "clouddeploy.rollouts.advance",
          "clouddeploy.rollouts.cancel",
          "clouddeploy.rollouts.create",
          "clouddeploy.rollouts.get",
          "clouddeploy.rollouts.ignoreJob",
          "clouddeploy.rollouts.list",
          "clouddeploy.rollouts.retryJob",
          "clouddeploy.rollouts.rollback",
          "clouddeploy.targets.create",
          "clouddeploy.targets.get",
          "clouddeploy.targets.getIamPolicy",
          "clouddeploy.targets.list",
          "clouddeploy.targets.update",
          "logging.logEntries.create",
          "run.executions.cancel",
          "run.executions.get",
          "run.executions.list",
          "run.jobs.get",
          "run.jobs.list",
          "run.jobs.run",
          "run.locations.list",
          "run.operations.get",
          "run.operations.list",
          "run.revisions.get",
          "run.revisions.list",
          "run.routes.get",
          "run.routes.list",
          "run.services.get",
          "run.services.list",
          "run.tasks.get",
          "run.tasks.list",
          "source.repos.get",
          "source.repos.list"
        ]
      }
    }
    service_accounts = {
      sa-job = {
        roles       = ["projects/c4hnrd-tools/roles/rolejob", "projects/c4hnrd-tools/roles/cdcloudrun"]
        description = "Service Account for running job services"
      },
      sa-pubsub = {
        roles       = ["roles/iam.serviceAccountTokenCreator", "roles/pubsub.publisher", "roles/pubsub.subscriber"]
        description = "Service Account for running pubsub services"
      },
      sa-api = {
        roles       = ["projects/c4hnrd-tools/roles/roleapi", "roles/cloudtrace.agent"]
        description = "Service Account for running api services"
      },
      sa-queue = {
        roles       = ["projects/c4hnrd-tools/roles/rolequeue"]
        description = "Service Account for running queue services"
      },
      github-actions = {
        roles       = ["projects/c4hnrd-tools/roles/cdcloudbuild", "projects/c4hnrd-tools/roles/cdclouddeploy", "roles/cloudbuild.builds.builder", "roles/cloudbuild.builds.editor", "roles/iam.serviceAccountTokenCreator", "roles/iam.serviceAccountUser", "roles/run.developer", "roles/run.viewer", "roles/storage.admin"]
        description = "A service account with permission to deploy from GitHub repository"
        resource_roles = [
          {
            resource = "projects/c4hnrd-tools/serviceAccounts/github-actions@c4hnrd-tools.iam.gserviceaccount.com"
            roles    = ["roles/cloudbuild.serviceAgent"]
            resource_type = "sa_iam_member"
          }
        ]
      }
    }
  }
}
