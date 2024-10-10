#!/bin/bash
ENV="prod"
TAG="prod"  # this might be different from env, e.g. sandbox vs tools
HOST_PROJECT_ID="c4hnrd"
TARGET_PROJECT_ID=""
SHARED_VPC_NAME="bcr-vpc"
HOST_PROJECT_ID="${HOST_PROJECT_ID}-${ENV}"
TARGET_PROJECT_ID="${TARGET_PROJECT_ID}-${ENV}"
SHARED_VPC_NAME="${SHARED_VPC_NAME}-${TAG}"

gcloud config set project $TARGET_PROJECT_ID

PROJECT_NUMBER=$(gcloud projects describe "${TARGET_PROJECT_ID}-${ENV}" --format="get(projectNumber)")
TARGET_PROJECT_CLOUD_RUN_SERVICE_AGENT="service-${PROJECT_NUMBER}@serverless-robot-prod.iam.gserviceaccount.com"

# attach project to VPC
gcloud compute $SHARED_VPC_NAME associated-projects add $TARGET_PROJECT_ID \
    --host-project=$HOST_PROJECT_ID

# enable attached Service APIs
gcloud services enable compute.googleapis.com --project=$TARGET_PROJECT_ID
gcloud services enable networkservices.googleapis.com --project=$TARGET_PROJECT_ID

# cloudrun permissions to access Shared VPC
gcloud projects add-iam-policy-binding $HOST_PROJECT_ID \
    --member="serviceAccount:${TARGET_PROJECT_CLOUD_RUN_SERVICE_AGENT}" \
   --role="roles/vpcaccess.user" --condition=None
gcloud projects add-iam-policy-binding $HOST_PROJECT_ID \
   --member="serviceAccount:${TARGET_PROJECT_CLOUD_RUN_SERVICE_AGENT}" \
   --role="roles/compute.viewer" --condition=None
