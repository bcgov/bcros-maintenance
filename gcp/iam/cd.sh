
#!/bin/bash

declare -a environments=("dev" "test" "tools" "prod" "integration" "sandbox")
declare -a projects=("a083gt" "bcrbk9" "c4hnrd" "eogruh" "gtksf3" "k973yf" "keee67" "okagqp" "sbgmug" "yfjq17" "yfthig" "p0q6jr")
declare -a service="cdcloudrun"

for ev in "${environments[@]}"
do
    for ns in "${projects[@]}"
    do
        echo "project: $ns-$ev"
        PROJECT_ID=$ns-$ev

        if [[ ! -z `gcloud projects describe ${PROJECT_ID} --verbosity=none` ]]; then
            gcloud config set project ${PROJECT_ID}

            PROJECT_NUMBER=`gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)"`

            ROLE_NAME="role$service"
            SA_FULL_NAME="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
            SA_ROLE="projects/${PROJECT_ID}/roles/$ROLE_NAME"

            # create service account and binding via Terraform

            # role binding - default cloud run service account
            gcloud projects add-iam-policy-binding ${PROJECT_ID} --condition=None --member="serviceAccount:331250273634-compute@developer.gserviceaccount.com" --role="$SA_ROLE"

            # role binding - default cloud build service account
            gcloud projects add-iam-policy-binding ${PROJECT_ID}  --condition=None --member="serviceAccount:331250273634@cloudbuild.gserviceaccount.com" --role="$SA_ROLE"

            # role binding - default cloud run robot service account
            SA_ROBOT_FULL_NAME="service-${PROJECT_NUMBER}@serverless-robot-prod.iam.gserviceaccount.com"
            gcloud projects add-iam-policy-binding ${PROJECT_ID} --condition=None --member="serviceAccount:$SA_ROBOT_FULL_NAME" --role="$SA_ROLE"

            # role binding - default cloud run robot service account in cloud deploy project
            SA_DEPLOY_ROLE="projects/c4hnrd-tools/roles/$ROLE_NAME"
            gcloud projects add-iam-policy-binding c4hnrd-tools --condition=None --member="serviceAccount:$SA_ROBOT_FULL_NAME" --role="$SA_DEPLOY_ROLE"
        fi
    done
done
