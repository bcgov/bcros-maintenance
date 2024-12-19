#!/bin/bash

REGION="us-west4"

declare -a projects=("mvnjri")
declare -a environments=("prod")

for ev in "${environments[@]}"
do
  for ns in "${projects[@]}"
  do
    PROJECT_ID="${ns}-${ev}"
    echo "Processing project: ${PROJECT_ID}"

    if gcloud projects describe "${PROJECT_ID}" >/dev/null 2>&1; then
      echo "Project ${PROJECT_ID} found. Proceeding..."

      gcloud config set project "${PROJECT_ID}"

      gcloud services enable apigateway.googleapis.com --project="${PROJECT_ID}"
      gcloud services enable servicemanagement.googleapis.com --project="${PROJECT_ID}"
      gcloud services enable servicecontrol.googleapis.com --project="${PROJECT_ID}"

      gcloud api-gateway apis create create-pam-grant --project="${PROJECT_ID}"

      gcloud api-gateway api-configs create create-pam-grant \
        --api=create-pam-grant \
        --openapi-spec=open_api_spec.yml \
        --project="${PROJECT_ID}"

      gcloud api-gateway gateways create create-pam-grant \
          --api=create-pam-grant \
          --api-config=create-pam-grant \
          --location="${REGION}" \
          --project="${PROJECT_ID}"

    else
      echo "Project ${PROJECT_ID} does not exist or cannot be accessed."
    fi
  done
done
