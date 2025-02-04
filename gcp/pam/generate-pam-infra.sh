#!/usr/local/bin/bash

# 1. Create secret with db user password
# 2. Update projects array - only add a single project id for the db if adding a single new db
# 3. Set up PAM for the project via console
# 4. Update list of users in PAM entitlement
# 5. Enable IAM authentication in db
# 6. Update apigee endpoint - need to include new URLs to the policy
# 7. Update audit flags - will cause database restart


REGION="northamerica-northeast1"
APIGEE_SA="apigee-prod-sa@okagqp-prod.iam.gserviceaccount.com"
BUCKET="gs://fin-warehouse"
DB_ROLES_BUCKET="${BUCKET}/users"

HOST_PROJECT_ID="c4hnrd"
# create the dataset only once
# bq mk --location=$REGION --dataset ${HOST_PROJECT_ID}-prod:pam_create_audit_log_prod

# declare -a projects=("mvnjri" "c4hnrd" "gtksf3" "yfjq17" "a083gt" "keee67" "eogruh" "k973yf")

declare -a projects=("k973yf")
declare -a environments=("prod")

declare -A DB_USERS
declare -A DB_NAMES
declare -A DB_INSTANCE_CONNECTION_NAMES

# Populate arrays with values specific to each project

DB_USERS["mvnjri-prod"]="pay"
DB_NAMES["mvnjri-prod"]="fin_warehouse"
DB_INSTANCE_CONNECTION_NAMES["mvnjri-prod"]="mvnjri-prod:northamerica-northeast1:fin-warehouse-prod"
DB_PASSWORD_SECRET_ID["mvnjri-prod"]="DATA_WAREHOUSE_PAY_PASSWORD"

DB_USERS["c4hnrd-prod"]="notifyuser,user4ca"
DB_NAMES["c4hnrd-prod"]="notify,docs"
DB_INSTANCE_CONNECTION_NAMES["c4hnrd-prod"]="c4hnrd-prod:northamerica-northeast1:notify-db-prod,c4hnrd-prod:northamerica-northeast1:common-db-prod"
DB_PASSWORD_SECRET_IDS["c4hnrd-prod"]="NOTIFY_USER_PASSWORD,USER4CA_PASSWORD"

DB_USERS["gtksf3-prod"]="postgres"
DB_NAMES["gtksf3-prod"]="auth-db"
DB_INSTANCE_CONNECTION_NAMES["gtksf3-prod"]="gtksf3-prod:northamerica-northeast1:auth-db-prod"
DB_PASSWORD_SECRET_IDS["gtksf3-prod"]="AUTH_USER_PASSWORD"

DB_USERS["yfjq17-prod"]="prodUser"
DB_NAMES["yfjq17-prod"]="bor"
DB_INSTANCE_CONNECTION_NAMES["yfjq17-prod"]="yfjq17-prod:northamerica-northeast1:bor-db-prod"
DB_PASSWORD_SECRET_IDS["yfjq17-prod"]="BOR_USER_PASSWORD"

DB_USERS["a083gt-prod"]="business-ar-api,business-api"
DB_NAMES["a083gt-prod"]="business-ar,legal-entities"
DB_INSTANCE_CONNECTION_NAMES["a083gt-prod"]="a083gt-prod:northamerica-northeast1:businesses-db-prod,a083gt-prod:northamerica-northeast1:businesses-db-prod"
DB_PASSWORD_SECRET_IDS["a083gt-prod"]="BUSINESS_AR_USER_PASSWORD,BUSINESS_USER_PASSWORD"

DB_USERS["eogruh-prod"]="bni-hub,vans-prod"
DB_NAMES["eogruh-prod"]="bni-hub,vans-db-prod"
DB_INSTANCE_CONNECTION_NAMES["keee67-prod"]="keee67-prod:northamerica-northeast1:bn-hub-prod,keee67-prod:northamerica-northeast1:bn-hub-prod"
DB_PASSWORD_SECRET_IDS["keee67-prod"]="BNI_USER_PASSWORD,VANS_USER_PASSWORD"

DB_USERS["eogruh-prod"]="user4ca"
DB_NAMES["eogruh-prod"]="ppr"
DB_INSTANCE_CONNECTION_NAMES["eogruh-prod"]="eogruh-prod:northamerica-northeast1:ppr-prod"
DB_PASSWORD_SECRET_IDS["keee67-prod"]="PPR_USER_PASSWORD"

DB_USERS["k973yf-prod"]="search_service"
DB_NAMES["k973yf-prod"]="search"
DB_INSTANCE_CONNECTION_NAMES["k973yf-prod"]="k973yf-prod:northamerica-northeast1:search-db-prod"
DB_PASSWORD_SECRET_IDS["k973yf-prod"]="SEARCH_USER_PASSWORD"


for ev in "${environments[@]}"
do
    for ns in "${projects[@]}"
    do
        PROJECT_ID="$ns-$ev"
        echo "Processing project: $PROJECT_ID"

        if [[ ! -z $(gcloud projects describe "${PROJECT_ID}" --verbosity=none) ]]; then
            gcloud config set project "$PROJECT_ID"

            PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format="get(projectNumber)")


            SERVICES=(
                "cloudfunctions.googleapis.com"
                "cloudscheduler.googleapis.com"
                "cloudbuild.googleapis.com"
                "privilegedaccessmanager.googleapis.com"
                "eventarc.googleapis.com"
                "cloudresourcemanager.googleapis.com"
            )

            gcloud services enable "${SERVICES[@]}" --project="${PROJECT_ID}"

            for SERVICE in "${SERVICES[@]}"; do
                while true; do
                    STATUS=$(gcloud services list --project="${PROJECT_ID}" --filter="config.name=${SERVICE}" --format="value(config.name)")

                    if [[ "${STATUS}" == "${SERVICE}" ]]; then
                        echo "Service ${SERVICE} is enabled."
                        break
                    else
                        echo "Waiting for service ${SERVICE} to be enabled..."
                        sleep 5
                    fi
                done
            done

            echo "All necesary APIs are enabled."


            # TODO patch cloudsql instance flags - careful as this will override existing flags, pgaudit flags will also cause db to restart, most likely need to do afterhours
            ## cloudsql.enable_anon=on,cloudsql.enable_pgaudit=on,pgaudit.log=read,write
            # gcloud sql instances patch INSTANCE_NAME \
            #   --database-flags=cloudsql_iam_authentication=on

            roles=(
            "roles/cloudsql.admin"
            "roles/iam.serviceAccountAdmin"
            "roles/cloudfunctions.invoker"
            "roles/resourcemanager.projectIamAdmin"
            "roles/cloudbuild.builds.builder"
            )

            for role in "${roles[@]}"; do
                gcloud projects add-iam-policy-binding "$PROJECT_ID" \
                    --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
                    --role="$role" || echo "Failed to assign $role for $PROJECT_ID"
            done

            ./generate-entitlements.sh "${projects[@]}"


            gcloud logging sinks create pam-request-grant-create_${ev} \
              bigquery.googleapis.com/projects/${HOST_PROJECT_ID}-${ev}/datasets/pam_create_audit_logs_${ev} \
              --log-filter='resource.type="cloud_function" AND resource.labels.function_name="pam-request-grant-create"' \
              --use-partitioned-tables

            gcloud logging sinks create cloudsql_audit_logs_${ev} \
              bigquery.googleapis.com/projects/${HOST_PROJECT_ID}-${ev}/datasets/cloudsql_audit_logs_${ev} \
              --log-filter="logName=\"projects/${PROJECT_ID}/logs/cloudaudit.googleapis.com%2Fdata_access\" AND resource.type=\"cloudsql_database\" AND protoPayload.serviceName=\"cloudsql.googleapis.com\" AND protoPayload.methodName=\"cloudsql.instances.query\"" \
              --use-partitioned-tables

            IFS=',' read -r -a DB_USER_ARRAY <<< ${DB_USERS[$PROJECT_ID]}
            IFS=',' read -r -a DB_NAME_ARRAY <<< ${DB_NAMES[$PROJECT_ID]}
            IFS=',' read -r -a DB_INSTANCE_ARRAY <<< ${DB_INSTANCE_CONNECTION_NAMES[$PROJECT_ID]}
            IFS=',' read -r -a DB_PASSWORD_ID_ARRAY <<< ${DB_PASSWORD_SECRET_IDS[$PROJECT_ID]}


            for ((i = 0; i < ${#DB_USER_ARRAY[@]}; i++))
            do
                DB_USER="${DB_USER_ARRAY[i]}"
                DB_NAME="${DB_NAME_ARRAY[i]}"
                DB_INSTANCE_CONNECTION_NAME="${DB_INSTANCE_ARRAY[i]}"
                DB_PASSWORD_SECRET_ID="${DB_PASSWORD_ID_ARRAY[i]}"
                DB_INSTANCE_NAME="${DB_INSTANCE_CONNECTION_NAME##*:}"

                FUNCTION_SUFFIX="${DB_NAME//_/-}"

                SERVICE_ACCOUNT=$(gcloud sql instances describe "${DB_INSTANCE_NAME}" --format="value(serviceAccountEmailAddress)")

                gsutil iam ch "serviceAccount:${SERVICE_ACCOUNT}:roles/storage.objectViewer" "${BUCKET}"

                for file in $(gsutil ls "${DB_ROLES_BUCKET}" | grep -v "/$"); do
                    echo "Importing ${file} into database ${DB_NAME}..."
                    gcloud --quiet sql import sql "${DB_INSTANCE_NAME}" "${file}" --database="${DB_NAME}" --user="${DB_USER}"
                    if [[ $? -ne 0 ]]; then
                        echo "Failed to import ${file}. Exiting."
                        exit 1
                    fi
                done

                gcloud secrets add-iam-policy-binding $DB_PASSWORD_SECRET_ID \
                --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
                --role="roles/secretmanager.secretAccessor"

                gcloud pubsub topics create "pam-revoke-topic-${FUNCTION_SUFFIX}"

                gcloud functions deploy "pam-grant-revoke-${FUNCTION_SUFFIX}" \
                    --runtime python312 \
                    --trigger-topic "pam-revoke-topic-${FUNCTION_SUFFIX}" \
                    --entry-point pam_event_handler \
                    --source cloud-functions/pam-grant-revoke \
                    --set-env-vars DB_INSTANCE_CONNECTION_NAME=${DB_INSTANCE_CONNECTION_NAME},PROJECT_NUMBER=${PROJECT_NUMBER} \
                    --region $REGION \
                    --retry

                gcloud functions deploy "pam-request-grant-create-${FUNCTION_SUFFIX}" \
                    --runtime python312 \
                    --trigger-http \
                    --entry-point create_pam_grant_request \
                    --source cloud-functions/pam-request-grant-create \
                    --set-env-vars DB_USER=${DB_USER},DB_NAME=${DB_NAME},DB_INSTANCE_CONNECTION_NAME=${DB_INSTANCE_CONNECTION_NAME},PROJECT_NUMBER=${PROJECT_NUMBER},PROJECT_ID=${PROJECT_ID},SECRET_ID=${DB_PASSWORD_SECRET_ID},PUBSUB_TOPIC="pam-revoke-topic-${FUNCTION_SUFFIX}" \
                    --region $REGION \
                    --no-allow-unauthenticated

                gcloud functions add-invoker-policy-binding "pam-request-grant-create-${FUNCTION_SUFFIX}" --member="serviceAccount:${APIGEE_SA}" --region=$REGION --project=${PROJECT_ID}
            done
        else
            echo "Project $PROJECT_ID not found or inaccessible."
        fi
    done
done
