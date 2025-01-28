#!/bin/bash

# declare -a projects=("mvnjri")

projects=("$@")

declare -a environments=("prod")

ENTITLEMENTS_FOLDER="entitlements"

if [[ ! -d "$ENTITLEMENTS_FOLDER" ]]; then
    echo "Error: Entitlements folder $ENTITLEMENTS_FOLDER not found!"
    exit 1
fi

OUTPUT_FILE="output.yaml"
REGION="global"

for ev in "${environments[@]}"
  do
      for ns in "${projects[@]}"
        do
          echo "project: $ns-$ev"
          PROJECT_ID=$ns-$ev

          if [[ ! -z `gcloud projects describe ${PROJECT_ID} --verbosity=none` ]]; then

              for INPUT_TEMPLATE_FILE in "$ENTITLEMENTS_FOLDER"/*.yaml; do
                  if [[ "$INPUT_TEMPLATE_FILE" != *-lists.yaml ]]; then

                      INPUT_LISTS_FILE="${INPUT_TEMPLATE_FILE%.yaml}-lists.yaml"

                      if [[ ! -f "$INPUT_LISTS_FILE" ]]; then
                          echo "Error: Input email lists file $INPUT_LISTS_FILE not found!"
                          continue  # Skip this template file and continue with the next one
                      fi

                      PRINCIPALS_JSON=$(yq eval -o=json '
                        .emailLists.requesters |
                        (map(select(test("@gov.bc.ca$")) | "user:" + .)) +
                        (map(select(test(".gserviceaccount.com$")) | "serviceAccount:" + .))
                      ' "$INPUT_LISTS_FILE")
                      APPROVER_PRINCIPALS_JSON=$(yq eval -o=json '.emailLists.approvers | map("user:" + .)' "$INPUT_LISTS_FILE")

                      ROLE_NAME=$(yq eval '.privilegedAccess.gcpIamAccess.roleBindings[0].role' "$INPUT_TEMPLATE_FILE")

                      yq eval "
                        .privilegedAccess.gcpIamAccess.resource = \"//cloudresourcemanager.googleapis.com/projects/$PROJECT_ID\" |
                        .eligibleUsers[0].principals = $PRINCIPALS_JSON |
                        .approvalWorkflow.manualApprovals.steps[0].approvers[0].principals = $APPROVER_PRINCIPALS_JSON |
                        .privilegedAccess.gcpIamAccess.roleBindings[0].role = \"projects/$PROJECT_ID/roles/$ROLE_NAME\"
                      " "$INPUT_TEMPLATE_FILE" > "$OUTPUT_FILE"

                      if [[ -f "$OUTPUT_FILE" ]]; then
                          echo "Replacements complete for $INPUT_TEMPLATE_FILE. Output saved to $OUTPUT_FILE."
                          gcloud config set project $PROJECT_ID

                          ENTITLEMENT="${INPUT_TEMPLATE_FILE#entitlements/}"
                          ENTITLEMENT="${ENTITLEMENT%.yaml}"

                          gcloud beta pam entitlements create \
                              "$ENTITLEMENT" \
                              --entitlement-file="$OUTPUT_FILE" \
                              --location="$REGION"
                      else
                          echo "Error: Output file $OUTPUT_FILE not generated for $INPUT_TEMPLATE_FILE."
                      fi
                  fi
              done
            fi
      done
  done
