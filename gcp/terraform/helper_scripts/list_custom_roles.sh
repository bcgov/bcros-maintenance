#!/bin/bash

# Utility script to list existing custom roles
declare -a projects=("mvnjri" "c4hnrd" "gtksf3" "yfjq17" "a083gt" "keee67" "eogruh" "k973yf" "yfthig" "bcrbk9" "p0q6jr" "sbgmug" "okagqp")
declare -a environments=("prod" "test" "dev" "sandbox" "tools" "integration" "train")

for ev in "${environments[@]}"; do
    for ns in "${projects[@]}"; do
        PROJECT_ID="$ns-$ev"
        echo "Processing project: $PROJECT_ID"

        if gcloud projects describe "$PROJECT_ID" --verbosity=none > /dev/null 2>&1; then
            gcloud config set project "$PROJECT_ID" > /dev/null 2>&1

            echo "Custom roles in project $PROJECT_ID:"
            gcloud iam roles list --project="$PROJECT_ID" --filter="name:projects/$PROJECT_ID/roles/"

            echo "----------------------------------------"
        else
            echo "Project $PROJECT_ID not found or inaccessible."
            echo "----------------------------------------"
        fi
    done
done
