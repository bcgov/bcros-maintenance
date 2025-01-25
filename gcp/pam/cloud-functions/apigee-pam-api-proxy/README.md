
# Instructions for Deploying API Proxy and Token Signing

### Run the following to zip the API proxy:

```bash
zip -r apiProxy.zip apiProxy
```

Then, import the archive via the Apigee menu in the GCP console.

**Note:** You can run the Apigee linting tool to debug:

```bash
apigeelint -s ./apigee-pam-api-proxy -f table.js --profile apigeex
```

(See installation instructions [here](https://github.com/apigee/apigeelint))

# How to set up authentication for apigee

### References:
- [Create short-lived credentials](https://cloud.google.com/iam/docs/create-short-lived-credentials-direct#rest_5)
- [Apigee to Cloud Function Auth](https://www.googlecloudcommunity.com/gc/Apigee/Apigee-To-Cloud-function-Auth/m-p/700286)
- [Apigee Samples - Cloud Functions](https://github.com/GoogleCloudPlatform/apigee-samples/tree/main/cloud-functions)
- [Manual Steps for Cloud Functions](https://github.com/GoogleCloudPlatform/apigee-samples/blob/main/cloud-functions/Manual-Steps.md)

### Test Signing Tokens via `gcloud`

1. **Permissions:**

```bash
gcloud projects add-iam-policy-binding okagqp-prod --member="user:andriy.bolyachevets@gov.bc.ca" --role="roles/iam.serviceAccountTokenCreator"
```

**Payload (payload.json):**

```json
{
  "audience": "<CLOUD_FUNCTION_URL>",
  "includeEmail": "true"
}
```

**Sign the JWT:**

```bash
gcloud iam service-accounts sign-jwt --iam-account="apigee-prod-sa@okagqp-prod.iam.gserviceaccount.com" payload.json signed_jwt.json
```

2. **Generate Token via Curl:**

```bash
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json; charset=utf-8" --data "@payload.json" "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/apigee-prod-sa@okagqp-prod.iam.gserviceaccount.com:generateIdToken"
```

Now, save the token in a variable:

```bash
SA_ID_TOKEN=$(curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json; charset=utf-8" --data "@payload.json" "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/apigee-prod-sa@okagqp-prod.iam.gserviceaccount.com:generateIdToken" | jq -r '.token')
```

3. **Call the Cloud Function URL with the Token:**

Make sure `apigee-prod-sa@okagqp-prod.iam.gserviceaccount.com` has the `Cloud Functions Invoker` role.

```bash
gcloud functions add-invoker-policy-binding "pam-request-grant-create" --member="serviceAccount:apigee-prod-sa@okagqp-prod.iam.gserviceaccount.com" --region="northamerica-northeast1" --project="<TARGET_PROJECT_ID>"
```

Now, call the Cloud Function:

```bash
curl -i -H "Authorization: Bearer $SA_ID_TOKEN" "<CLOUD_FUNCTION_URL>" \
        -H "Content-Type: application/json" \
        -d '{
       "assignee": "...",
       "entitlement": "...",
       "duration": 5,
       "robot": ...,
       "permissions": "...",
       "database": "..."
}'
```

### Test Apigee Endpoint

Test the Apigee proxy endpoint:

```bash
curl -X POST "<APIGEE_PROXY_URL>"
     -H "Content-Type: application/json" \
     -H "X-API-Key: ..." \
     -d '{
           "assignee": "...",
           "entitlement": "...",
           "duration": 5,
           "robot": ...,
           "permissions": "...",
           "database": "..."
}'
```
