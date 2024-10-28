#!/bin/bash

declare -a projects=("a083gt" "bcrbk9" "c4hnrd" "eogruh" "gtksf3" "k973yf" "keee67" "okagqp" "sbgmug" "yfjq17" "yfthig")
declare -a environments=("dev" "test" "tools" "prod" "integration" "sandbox")


ROLE_NAME="SRE"
ROLE_FILE="role-sre.yaml"

for ev in "${environments[@]}"
   do
       for ns in "${projects[@]}"
       do
          echo "project: $ns-$ev"
          PROJECT_ID=$ns-$ev
          if [[ ! -z `gcloud projects describe ${PROJECT_ID} --verbosity=none` ]]; then
              gcloud config set project ${PROJECT_ID}
              # list all enabled services
              gcloud services list --enabled > enabled-api.txt

              # get the IAM owner role description
              gcloud iam roles describe roles/owner > $ROLE_FILE

              touch api-keywords.txt

              while IFS= read -r enabled_api; do
                  if [[ "$enabled_api" == *".googleapis.com"* ]]; then
                      # extract the API name before .googleapis.com
                      api_name=$(echo "$enabled_api" | sed 's/\.googleapis\.com.*//')
                      echo "$api_name" >> api-keywords.txt
                  fi
              done < enabled-api.txt

              grep -E -f <(sed 's/$/\\./' api-keywords.txt) $ROLE_FILE > filtered-role-sre.yaml

              rm $ROLE_FILE
              rm api-keywords.txt
              rm enabled-api.txt

              (echo "title: "Role SRE"
description: "Role for SRE."
stage: "GA"
includedPermissions:" && cat filtered-role-sre.yaml) > $ROLE_FILE

              rm filtered-role-sre.yaml

              create/update SRE role
              if [[ -z `gcloud iam roles describe $ROLE_NAME --project=${PROJECT_ID} --verbosity=none` ]]; then
                  gcloud iam roles create $ROLE_NAME --quiet --project=${PROJECT_ID} --file=$ROLE_FILE
              else
                  gcloud iam roles update $ROLE_NAME --quiet --project=${PROJECT_ID} --file=$ROLE_FILE
              fi
          fi
      done
done
