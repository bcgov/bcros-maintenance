
#!/bin/bash

declare -a users=("bcregistry.sre@gov.bc.ca")

declare -a projects=("a083gt" "bcrbk9" "c4hnrd" "eogruh" "gtksf3" "k973yf" "keee67" "okagqp" "sbgmug" "yfjq17" "yfthig")

declare -a environments=("dev" "test" "tools" "prod" "integration" "sandbox")
declare -a roles=("developer")

for user in "${users[@]}"
do
    echo "user: $user"
    for ev in "${environments[@]}"
    do
        for ns in "${projects[@]}"
        do
            echo "project: $ns-$ev"
            PROJECT_ID=$ns-$ev

            if [[ ! -z `gcloud projects describe ${PROJECT_ID} --verbosity=none` ]]; then
                gcloud config set project ${PROJECT_ID}

                for ro in "${roles[@]}"
                do
                    ROLE_NAME="role$ro"
                    FULL_ROLE_NAME="projects/${PROJECT_ID}/roles/$ROLE_NAME"

                    echo "role: $ROLE_NAME"

                    # create/update developer role via Terraform

                    gcloud projects add-iam-policy-binding $PROJECT_ID \
                        --member user:$user \
                        --role=$FULL_ROLE_NAME \
                        --condition=None --verbosity=none --quiet
                done
            fi
        done
    done
done
