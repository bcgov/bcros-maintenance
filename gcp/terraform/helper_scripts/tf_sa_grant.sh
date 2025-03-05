#!/bin/bash

# script to assing necessary grants to terraform service account

declare -a projects=("mvnjri" "c4hnrd" "gtksf3" "yfjq17" "a083gt" "keee67" "eogruh" "k973yf" "yfthig" "bcrbk9" "p0q6jr" "sbgmug" "okagqp")
declare -a environments=("prod" "test" "dev" "sandbox" "tools" "integration" "train")

# declare -a projects=("k973yf")
# declare -a environments=("-tools")

for ev in "${environments[@]}"; do
    for ns in "${projects[@]}"; do
        PROJECT_ID="$ns-$ev"
        echo "Processing project: $PROJECT_ID"

        if gcloud projects describe "$PROJECT_ID" --verbosity=none > /dev/null 2>&1; then
            gcloud config set project "$PROJECT_ID" > /dev/null 2>&1

            echo "Assigning terraform service account roles in $PROJECT_ID:"

            gcloud projects add-iam-policy-binding $PROJECT_ID \
                --member="serviceAccount:terraform-sa@c4hnrd-tools.iam.gserviceaccount.com" \
                --role="roles/resourcemanager.projectIamAdmin"

            gcloud projects add-iam-policy-binding $PROJECT_ID \
                --member="serviceAccount:terraform-sa@c4hnrd-tools.iam.gserviceaccount.com" \
                --role="roles/iam.roleAdmin"

            gcloud projects add-iam-policy-binding $PROJECT_ID \
                --member="serviceAccount:terraform-sa@c4hnrd-tools.iam.gserviceaccount.com" \
                --role="roles/iam.serviceAccountAdmin"

            gcloud projects add-iam-policy-binding $PROJECT_ID \
                --member="serviceAccount:terraform-sa@c4hnrd-tools.iam.gserviceaccount.com" \
                --role="roles/storage.admin"

            gcloud projects add-iam-policy-binding $PROJECT_ID \
                --member="serviceAccount:terraform-sa@c4hnrd-tools.iam.gserviceaccount.com" \
                --role="roles/run.admin"

            gcloud projects add-iam-policy-binding $PROJECT_ID \
                --member="serviceAccount:terraform-sa@c4hnrd-tools.iam.gserviceaccount.com" \
                --role="roles/secretmanager.admin"


            gcloud projects add-iam-policy-binding $PROJECT_ID \
                --member="serviceAccount:terraform-sa@c4hnrd-tools.iam.gserviceaccount.com" \
                --role="roles/pubsub.admin"

            gcloud projects add-iam-policy-binding $PROJECT_ID \
                --member="serviceAccount:terraform-sa@c4hnrd-tools.iam.gserviceaccount.com" \
                --role="roles/artifactregistry.admin"

            echo "----------------------------------------"
        else
            echo "Project $PROJECT_ID not found or inaccessible."
            echo "----------------------------------------"
        fi
    done
done
