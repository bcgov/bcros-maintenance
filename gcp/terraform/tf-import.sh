#!/bin/bash

# utility script for importing existing gcp roles into terraform state

# declare -a projects=("mvnjri" "c4hnrd" "gtksf3" "yfjq17" "a083gt" "keee67" "eogruh" "k973yf" "yfthig" "bcrbk9" "sbgmug" "okagqp")
# declare -a project_alias=("analytics-int" "common" "connect" "bor" "bcr-businesses" "business-number-hub" "ppr" "search" "web-presence" "strr" "analytics-ext" "api-gateway")
# declare -a environments=("prod" "test" "dev" "sandbox" "tools" "integration" "train")


declare -a projects=("yfjq17")
declare -a project_alias=("bor")
declare -a environments=("dev")

declare -a roles=("rolequeue" "SRE" "rolecdcloudrun" "roleapi" "roledeveloper" "rolejob" "roleitops")

for ev in "${environments[@]}"; do
    for i in "${!projects[@]}"; do
        ns="${projects[$i]}"
        alias="${project_alias[$i]}-${ev}"
        PROJECT_ID="$ns-$ev"

        echo "Processing project: $PROJECT_ID (alias: $alias)"

        if gcloud projects describe "$PROJECT_ID" --verbosity=none > /dev/null 2>&1; then
          gcloud config set project "$PROJECT_ID" > /dev/null 2>&1

          for ROLE_ID in "${roles[@]}"; do
              echo "Importing role $ROLE_ID in project $PROJECT_ID (alias: $alias)..."

              terraform import -var="GOOGLE_CREDENTIALS=$(cat ./c4hnrd-prod-0ee4a8451a88.json)" \
                "module.iam[\"${alias}\"].google_project_iam_custom_role.custom_roles[\"${ROLE_ID}\"]" \
                "projects/${PROJECT_ID}/roles/${ROLE_ID}"
          done
        else
          echo "Project ${PROJECT_ID} does not exist"
        fi
    done
done
