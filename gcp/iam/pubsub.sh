
#!/bin/bash

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

                # create service account
                if [[ -z `gcloud iam service-accounts describe $SA_FULL_NAME --project=${PROJECT_ID} --verbosity=none` ]]; then
                    gcloud iam service-accounts create $SA_NAME \
                        --description="$SA_DESCRIPTION" \
                        --display-name="$SA_NAME"
                fi

                # role binding
                gcloud projects add-iam-policy-binding ${PROJECT_ID} \
                    --member="serviceAccount:$SA_FULL_NAME" \
                    --role="roles/pubsub.publisher"

                gcloud projects add-iam-policy-binding ${PROJECT_ID} \
                    --member="serviceAccount:$SA_FULL_NAME" \
                    --role="roles/pubsub.subscriber"

                gcloud projects add-iam-policy-binding ${PROJECT_ID} \
                    --member="serviceAccount:$SA_FULL_NAME" \
                    --role="roles/iam.serviceAccountTokenCreator"
                gcloud projects add-iam-policy-binding ${PROJECT_ID} \
                    --member="serviceAccount:$SA_FULL_NAME" \
                    --role="roles/run.invoker"

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
