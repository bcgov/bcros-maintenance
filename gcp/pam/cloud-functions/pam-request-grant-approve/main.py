import base64
import json
import logging
import requests
import os
from google.cloud import secretmanager

project_number = os.environ['PROJECT_NUMBER']
pam_api_secret_id = os.environ['PAM_API_KEY_SECRET_ID']
pam_api_secret_name = f"projects/{project_number}/secrets/{pam_api_secret_id}/versions/latest"
client = secretmanager.SecretManagerServiceClient()
key_response = client.access_secret_version(name=pam_api_secret_name)
api_key = key_response.payload.data.decode("UTF-8")
pam_url_secret_id = os.environ['PAM_API_URL_SECRET_ID']
pam_url_secret_name = f"projects/{project_number}/secrets/{pam_url_secret_id}/versions/latest"
client = secretmanager.SecretManagerServiceClient()
url_response = client.access_secret_version(name=pam_url_secret_name)
api_url = url_response.payload.data.decode("UTF-8")

def pam_event_handler(event, context):
    try:
        logging.info(f"Received event: {event}")
        pubsub_message = base64.b64decode(event['data']).decode('utf-8')
        logging.info(f"Decoded message: {pubsub_message}")

        request_json = json.loads(pubsub_message)

        email = (
            request_json.get("protoPayload", {})
                        .get("metadata", {})
                        .get("updatedGrant", {})
                        .get("requester", {})
        )

        if not email:
            logging.error("Email not found in timeline's approved event")
            return "Email not found in the Pub/Sub message payload", 400

        role_bindings = (
            request_json.get("protoPayload", {})
                        .get("metadata", {})
                        .get("updatedGrant", {})
                        .get("privilegedAccess", {})
                        .get("gcpIamAccess", {})
                        .get("roleBindings", [])
        )

        role = None
        if role_bindings:
            role = role_bindings[0].get("role")

        if not role:
            logging.error("Role not found in roleBindings")
            return "Role not found in the Pub/Sub message payload", 400

        role_name = role.split('/')[-1]

        requested_duration = (
            request_json.get("protoPayload", {})
                       .get("metadata", {})
                       .get("updatedGrant", {})
                       .get("requestedDuration", None)
        )

        if not requested_duration:
            logging.error("Duration not found in roleBindings")
            return "Duration not found in the Pub/Sub message payload", 400

        minutes = int(''.join(filter(str.isdigit, requested_duration))) // 60

        payload = {
            "assignee": email,
            "entitlement": role_name,
            "duration": minutes,
            "robot": False
        }

        logging.warning(f"Constructed payload: {payload}")

        headers = {
            "Content-Type": "application/json",
            "X-API-Key": api_key
        }
        response = requests.post(api_url, json=payload, headers=headers)

        logging.warning(f"Response from target Cloud Function: {response.status_code}, {response.text}")

        if response.status_code == 200:
            return "Payload successfully sent to target Cloud Function", 200
        else:
            return f"Failed to send payload: {response.status_code}, {response.text}", 500

    except Exception as e:
        logging.error(f"Error processing Pub/Sub event: {e}")
        return f"Error: {str(e)}", 500
