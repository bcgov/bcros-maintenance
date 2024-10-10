#!/bin/bash

# Variables
TARGET_PROJECT_ID=""
INSTANCE_NAME=""
ENV="prod"
TAG="prod" # this might be different from env, e.g. sandbox vs tools
REGION="northamerica-northeast1"
HOST_PROJECT_ID="c4hnrd"
POSTGRES_VERSION="POSTGRES_15"
SHARED_VPC_NAME="bcr-vpc"

gcloud config set project "${TARGET_PROJECT_ID}-${ENV}"

gcloud services enable servicenetworking.googleapis.com --project="${TARGET_PROJECT_ID}-${ENV}"

gcloud sql instances create "${INSTANCE_NAME}-${TAG}" \
    --database-version=$POSTGRES_VERSION \
    --region=$REGION \
    --storage-type=SSD \
    --storage-auto-increase \
    --backup-start-time=00:00 \
    --enable-point-in-time-recovery \
    --retained-backups-count=7 \
    --retained-transaction-log-days=7 \
    --availability-type=regional \
    --tier=db-custom-4-16384 \
    --storage-size=100GB \
    --project="${TARGET_PROJECT_ID}-${ENV}" \
    --maintenance-window-day=MON \
    --maintenance-window-hour=4 \
    --backup-start-time=08:00 \
    --network="projects/${HOST_PROJECT_ID}-${ENV}/global/networks/${SHARED_VPC_NAME}-${TAG}"
