#!/bin/bash

declare -a projects=("a083gt" "bcrbk9" "c4hnrd" "eogruh" "gtksf3" "k973yf" "keee67" "okagqp" "sbgmug" "yfjq17" "yfthig")
declare -a environments=("dev" "test" "tools" "prod" "integration" "sandbox")


ROLE_NAME="SRE"
ROLE_FILE="role-sre.yaml"
ENABLED_API_DUMP="enabled-api-keywords.txt"
ALL_API_DUMP="all-api-keywords.txt"
DISABLED_API_DUMP="disabled-api-keywords.txt"
EXCLUDED_API="excluded-api-list.txt"
EXCLUDED_PERMISSIONS="excluded-permission-list.txt"

FILTERED_ROLE_FILE="filtered-role-sre.yaml"


# Create a consolidated list of all enabled APIs for all projects
touch "${ENABLED_API_DUMP}"

for ev in "${environments[@]}"; do
    for ns in "${projects[@]}"; do
        PROJECT_ID="${ns}-${ev}"
        echo "Processing project: ${PROJECT_ID}"

        if gcloud projects describe "${PROJECT_ID}" --quiet --verbosity=none >/dev/null 2>&1; then
            gcloud config set project "${PROJECT_ID}"

            # List enabled services for this project and append unique APIs
            gcloud services list --enabled | grep "\.googleapis\.com" | sed 's/\.googleapis\.com.*//' >> "${ENABLED_API_DUMP}"

            # List all APIs
            gcloud services list --available | grep "\.googleapis\.com" | sed 's/\.googleapis\.com.*//' >> "${ALL_API_DUMP}"


        else
            echo "Project ${PROJECT_ID} does not exist or cannot be accessed. Skipping."
        fi
    done
done

# Remove duplicate entries
sort -u -o "${ENABLED_API_DUMP}" "${ENABLED_API_DUMP}"
# Remove duplicate entries
sort -u -o "${ALL_API_DUMP}" "${ALL_API_DUMP}"

comm -13 "${ENABLED_API_DUMP}" "${ALL_API_DUMP}" > "${DISABLED_API_DUMP}"

# Generate the folder-level IAM role description
gcloud iam roles describe roles/owner > "${ROLE_FILE}"
cat "${EXCLUDED_API}" >> "${DISABLED_API_DUMP}"
sort -u -o "${DISABLED_API_DUMP}" "${DISABLED_API_DUMP}"

grep -v -E "^-\ ($(sed 's/$/\\./' "${DISABLED_API_DUMP}" | tr '\n' '|' | sed 's/|$//'))" "${ROLE_FILE}" > "${FILTERED_ROLE_FILE}"

# Need this role for managing VPC Connectors
gcloud iam roles describe roles/compute.networkUser >> "${FILTERED_ROLE_FILE}"

grep -Ev "^-\s($(awk '{print $1}' "${EXCLUDED_PERMISSIONS}" | paste -sd '|' -))\s*$" "${FILTERED_ROLE_FILE}" > temp_file && mv temp_file "${FILTERED_ROLE_FILE}"

sort -u -o "${FILTERED_ROLE_FILE}" "${FILTERED_ROLE_FILE}"

(echo 'title: "Role SRE"'
echo 'description: "Role for SRE."'
echo 'stage: "GA"'
echo 'includedPermissions:'
grep '^- ' "${FILTERED_ROLE_FILE}") > "$ROLE_FILE"


# Clean up temporary files
rm "${FILTERED_ROLE_FILE}" "${ENABLED_API_DUMP}" "${DISABLED_API_DUMP}" "{$ALL_API_DUMP}"

for ev in "${environments[@]}"
   do
       for ns in "${projects[@]}"
       do
          echo "project: $ns-$ev"
          PROJECT_ID=$ns-$ev
          if [[ -z `gcloud iam roles describe $ROLE_NAME --project=${PROJECT_ID} --verbosity=none` ]]; then
              gcloud iam roles create $ROLE_NAME --quiet --project=${PROJECT_ID} --file=$ROLE_FILE
          else
              gcloud iam roles update $ROLE_NAME --quiet --project=${PROJECT_ID} --file=$ROLE_FILE
          fi
      done
done
