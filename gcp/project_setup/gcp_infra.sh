#!/bin/bash
ENV="prod"
TAG="prod"  # this might be different from env, e.g. sandbox vs tools
HOST_PROJECT_ID="c4hnrd"
TARGET_PROJECT_ID=""
HOST_PROJECT_ID="${HOST_PROJECT_ID}-${ENV}"
TARGET_PROJECT_ID="${TARGET_PROJECT_ID}-${ENV}"

gcloud config set project $TARGET_PROJECT_ID

# create log sink
gcloud logging sinks create cloud_run_errors_${TAG} \
bigquery.googleapis.com/projects/${HOST_PROJECT_ID}/datasets/cloud_run_logs_${TAG} \
--log-filter='resource.type="cloud_run_revision" AND severity="ERROR"' \
--use-partitioned-tables


# create alerts
ALERT_POLICIES_DIR="alert_policies"

for policy_file in "$ALERT_POLICIES_DIR"/*.json; do
  policy_name=$(basename "$policy_file")

  echo "Processing $policy_name..."

  envsubst < "$policy_file" > alert_policy.json
  gcloud alpha monitoring policies create --policy-from-file=alert_policy.json

  if [ $? -eq 0 ]; then
    echo "Successfully created alert policy from $policy_name."
  else
    echo "Failed to create alert policy from $policy_name."
  fi

  rm -f alert_policy.json

done
