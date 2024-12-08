#!/bin/bash

REGION="northamerica-northeast1"

declare -a projects=("mvnjri")
declare -a environments=("prod")
DB_USER="pay"
DB_NAME="fin_warehouse"
SECRET_ID="DATA_WAREHOUSE_PAY_PASSWORD"
DB_INSTANCE_CONNECTION_NAME="mvnjri-prod:northamerica-northeast1:fin-warehouse-prod"

for ev in "${environments[@]}"
  do
      for ns in "${projects[@]}"
        do
          echo "project: $ns-$ev"
          PROJECT_ID=$ns-$ev

          if [[ ! -z `gcloud projects describe ${PROJECT_ID} --verbosity=none` ]]; then

            gcloud config set project $PROJECT_ID

            gcloud services enable eventarc.googleapis.com

            gcloud pubsub topics create pam-grant-topic
            gcloud pubsub topics create pam-revoke-topic

            PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format="get(projectNumber)")

            gcloud pubsub topics add-iam-policy-binding pam-grant-topic \
            --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-logging.iam.gserviceaccount.com" \
            --role="roles/pubsub.publisher"

            gcloud pubsub topics add-iam-policy-binding pam-revoke-topic \
            --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-logging.iam.gserviceaccount.com" \
            --role="roles/pubsub.publisher"

            gcloud secrets add-iam-policy-binding DATA_WAREHOUSE_SA_TOKEN \
            --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
            --role="roles/secretmanager.secretAccessor"

            gcloud logging sinks create pam-grant-logs-sink \
            pubsub.googleapis.com/projects/${PROJECT_ID}/topics/pam-grant-topic \
            --log-filter='resource.type="audited_resource" AND protoPayload.methodName="PAMActivateGrant"'

            gcloud logging sinks create pam-revoke-logs-sink \
            pubsub.googleapis.com/projects/${PROJECT_ID}/topics/pam-revoke-topic \
            --log-filter='(resource.type="audited_resource" AND (protoPayload.methodName="PAMEndGrant" OR protoPayload.methodName="PAMDeleteGrant")) OR protoPayload.methodName="google.cloud.privilegedaccessmanager.v1alpha.PrivilegedAccessManager.RevokeGrant"'

            gcloud projects add-iam-policy-binding "$PROJECT_ID" \
              --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
              --role="roles/secretmanager.secretAccessor"

            gcloud functions deploy pam-update-db-grants \
              --runtime python312 \
              --trigger-topic pam-grant-topic \
              --entry-point pam_event_handler \
              --source cloud-functions/pam-update-db-grants \
              --set-env-vars DB_USER=${DB_USER},DB_NAME=${DB_NAME},DB_INSTANCE_CONNECTION_NAME=${DB_INSTANCE_CONNECTION_NAME},PROJECT_NUMBER=${PROJECT_NUMBER},SECRET_ID=${SECRET_ID} \
              --region  $REGION \
              --retry

            gcloud functions deploy pam-revoke-db-grants \
              --runtime python312 \
              --trigger-topic pam-revoke-topic \
              --entry-point pam_event_handler \
              --source cloud-functions/pam-revoke-db-grants \
              --set-env-vars DB_USER=${DB_USER},DB_NAME=${DB_NAME},DB_INSTANCE_CONNECTION_NAME=${DB_INSTANCE_CONNECTION_NAME},PROJECT_NUMBER=${PROJECT_NUMBER},SECRET_ID=${SECRET_ID} \
              --region  $REGION \
              --retry

          fi
      done
  done
