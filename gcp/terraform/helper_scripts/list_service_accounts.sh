#!/bin/bash

# Utility script to list existing service account iam bindings - resource specific permissions are pretty slow
declare -a projects=("mvnjri" "c4hnrd" "gtksf3" "yfjq17" "a083gt" "keee67" "eogruh" "k973yf" "yfthig" "bcrbk9" "p0q6jr" "sbgmug" "okagqp")
declare -a environments=("prod" "test" "dev" "sandbox" "tools" "integration" "train")

for ev in "${environments[@]}"; do
    for ns in "${projects[@]}"; do
        PROJECT_ID="$ns-$ev"
        echo "Processing project: $PROJECT_ID"

        # Check if the project exists and is accessible
        if gcloud projects describe "$PROJECT_ID" --verbosity=none > /dev/null 2>&1; then
            # Set the current project
            gcloud config set project "$PROJECT_ID" > /dev/null 2>&1

            SERVICE_ACCOUNTS=$(gcloud iam service-accounts list --project="$PROJECT_ID" \
              --filter="NOT name:compute NOT name:appspot NOT name:cloudsql NOT name:serverless-robot NOT name:firebase-adminsdk NOT name:sa-api NOT name:sa-pubsub NOT name:sa-job NOT name:sa-queue" \
              --format="value(email)")

            for SA_EMAIL in $SERVICE_ACCOUNTS; do
                echo "Service Account: $SA_EMAIL"

                # Get roles in the current project
                echo "Roles in current project ($PROJECT_ID):"
                gcloud projects get-iam-policy "$PROJECT_ID" \
                    --flatten="bindings[].members" \
                    --format="table(bindings.role)" \
                    --filter="bindings.members:serviceAccount:$SA_EMAIL"

                # Get roles in external projects

                echo "Roles in external projects:"
                ALL_PROJECTS=$(gcloud projects list --format="value(projectId)")
                for EXT_PROJECT_ID in $ALL_PROJECTS; do
                    if [ "$EXT_PROJECT_ID" != "$PROJECT_ID" ]; then
                        ROLES=$(gcloud projects get-iam-policy "$EXT_PROJECT_ID" \
                            --flatten="bindings[].members" \
                            --format="value(bindings.role)" \
                            --filter="bindings.members:serviceAccount:$SA_EMAIL")
                        if [ -n "$ROLES" ]; then
                            echo "Project: $EXT_PROJECT_ID"
                            echo "$ROLES"
                        fi
                    fi
                done

                # Get resource-specific permissions across all projects
                echo "Resource-specific permissions across all projects:"
                for SEARCH_PROJECT_ID in $ALL_PROJECTS; do
                    echo "Searching in project: $SEARCH_PROJECT_ID"
                    gcloud services enable cloudasset.googleapis.com --project=$SEARCH_PROJECT_ID --quiet

                    gcloud asset search-all-iam-policies --scope="projects/$SEARCH_PROJECT_ID" \
                        --query="policy:$SA_EMAIL" \
                        --format="table(resource, policy.bindings.role)"
                done

                echo "----------------------------------------"
            done
        else
            echo "Project $PROJECT_ID not found or inaccessible."
            echo "----------------------------------------"
        fi
    done
done
