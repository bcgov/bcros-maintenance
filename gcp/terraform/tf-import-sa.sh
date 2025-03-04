#!/bin/bash

# utility script for importing existing service accounts / iam bindings into terraform state

# declare -a projects=("mvnjri" "c4hnrd" "gtksf3" "yfjq17" "a083gt" "keee67" "eogruh" "k973yf" "yfthig" "bcrbk9" "sbgmug" "okagqp")
# declare -a environments=("prod")
# declare -a project_alias=("analytics-int" "common" "connect" "bor" "bcr-businesses" "business-number-hub" "ppr" "search" "web-presence" "strr" "analytics-ext" "api-gateway")

declare -a projects=("c4hnrd")
declare -a project_alias=("common")
declare -a environments=("tools")
declare -a service_accounts=("github-actions")


# Loop through each project
for ev in "${environments[@]}"; do
    for i in "${!projects[@]}"; do
        ns="${projects[$i]}"
        alias="${project_alias[$i]}-${ev}"
        PROJECT_ID="$ns-$ev"

        echo "Processing project: $PROJECT_ID (alias: $alias)"

        if gcloud projects describe "$PROJECT_ID" --verbosity=none > /dev/null 2>&1; then
          gcloud config set project "$PROJECT_ID" > /dev/null 2>&1

          for SERVICE_ACCOUNT_ID in "${service_accounts[@]}"; do
              # Construct the full service account email
              SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

              echo "Importing service account $SERVICE_ACCOUNT_EMAIL in project $PROJECT_ID (alias: $alias)..."

              terraform import -var="GOOGLE_CREDENTIALS=$(cat ./c4hnrd-prod-0ee4a8451a88.json)" \
                "module.iam[\"${alias}\"].google_service_account.sa[\"${SERVICE_ACCOUNT_ID}\"]" \
                "projects/${PROJECT_ID}/serviceAccounts/${SERVICE_ACCOUNT_EMAIL}"

              # Retrieve IAM bindings for the service account
              echo "Retrieving IAM bindings for service account $SERVICE_ACCOUNT_EMAIL..."

              IAM_BINDINGS=$(gcloud projects get-iam-policy "$PROJECT_ID" \
                --flatten="bindings[].members" \
                --format="table(bindings.role)" \
                --filter="bindings.members:serviceAccount:${SERVICE_ACCOUNT_EMAIL}")

              # Parse and import IAM bindings
              while IFS= read -r ROLE; do
                  if [[ -n "$ROLE" && "$ROLE" != "ROLE" ]]; then
                      echo "Importing IAM binding for role $ROLE on service account $SERVICE_ACCOUNT_EMAIL..."

                      terraform import -var="GOOGLE_CREDENTIALS=$(cat ./c4hnrd-prod-0ee4a8451a88.json)" \
                        "module.iam[\"${alias}\"].google_project_iam_member.iam_members[\"${PROJECT_ID}-${SERVICE_ACCOUNT_ID}-${ROLE}\"]" \
                        "projects/${PROJECT_ID} ${ROLE} serviceAccount:${SERVICE_ACCOUNT_EMAIL}"
                  fi
              done <<< "$IAM_BINDINGS"
          done
        else
          # Project does not exist
          echo "Project ${PROJECT_ID} does not exist"
        fi
    done
done


# terraform import -var="GOOGLE_CREDENTIALS=$(cat ./c4hnrd-prod-0ee4a8451a88.json)" \
#   "module.iam[\"common-test\"].google_service_account.sa[\"doc-test-sa\"]" \
#     "projects/c4hnrd-test/serviceAccounts/doc-test-sa@c4hnrd-test.iam.gserviceaccount.com"

# terraform import -var="GOOGLE_CREDENTIALS=$(cat ./c4hnrd-prod-0ee4a8451a88.json)" \
#   "module.iam[\"search-test\"].google_project_iam_member.external_iam_members[\"k973yf-dev-gha-wif-roles/compute.imageUser\"]" \
#   "projects/k973yf-dev roles/compute.imageUser serviceAccount:gha-wif@k973yf-test.iam.gserviceaccount.com"


# terraform state rm 'module.iam["bor-dev"].google_service_account.sa["sa-queue"]'
# terraform state rm 'module.iam["bor-dev"].google_project_iam_custom_role.custom_roles["SRE"]'
# │ The configuration for the given import module.iam["bor-sandbox"].google_project_iam_member.iam_members["a083gt-tools-sa-job-projects/a083gt-tools/roles/rolejob"] does not exist. All target instances must have an associated configuration to be
