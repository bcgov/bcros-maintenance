#!/bin/bash

# first, create service account / role binding via Terraform

declare -a environments=("dev" "test" "tools" "prod" "integration" "sandbox")
declare -a projects=("" "")
declare -a services=("pubsub")

for ev in "${environments[@]}"
do
    for ns in "${projects[@]}"
    do
        echo "project: $ns-$ev"
        PROJECT_ID=$ns-$ev

        if [[ ! -z `gcloud projects describe ${PROJECT_ID} --verbosity=none` ]]; then
            gcloud config set project ${PROJECT_ID}

            for se in "${services[@]}"
            do
                SA_NAME="sa-$se"
                SA_FULL_NAME="$SA_NAME@${PROJECT_ID}.iam.gserviceaccount.com"
                SA_DESCRIPTION="Service Account for running $se services"

                # create key
                gcloud iam service-accounts keys create ${SA_NAME}-${PROJECT_ID}.json --iam-account=${SA_FULL_NAME}

                # encode key
                echo "project: $ns-$ev \n" >> key.txt
                echo "GCP_AUTH_KEY=$(cat ${SA_NAME}-${PROJECT_ID}.json | base64)" >> key.txt

                rm ${SA_NAME}-${PROJECT_ID}.json
                #gcloud iam service-accounts list --filter $SA_NAME
                #gcloud iam roles describe $ROLE_NAME --project=${PROJECT_ID}
            done
        fi
    done
done
