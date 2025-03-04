
#!/bin/bash

declare -a users=("jose.kudiyirippil@gov.bc.ca" "ali.hamood@gov.bc.ca" "avni.salhotra@gov.bc.ca")

declare -a projects=("a083gt" "bcrbk9" "c4hnrd" "eogruh" "gtksf3" "k973yf" "keee67" "okagqp" "sbgmug" "yfjq17" "yfthig" "p0q6jr")

declare -a environments=("dev" "test" "tools" "prod" "integration" "sandbox")
declare -a roles=("SRE")

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
                    ROLE_NAME="$ro"
                    FULL_ROLE_NAME="projects/${PROJECT_ID}/roles/$ROLE_NAME"
                    ROLE_FILE=role-$ro.yaml

                    gcloud projects add-iam-policy-binding $PROJECT_ID \
                        --member user:$user \
                        --role=$FULL_ROLE_NAME \
                        --condition=None --verbosity=none --quiet
                done
            fi
        done
    done
done