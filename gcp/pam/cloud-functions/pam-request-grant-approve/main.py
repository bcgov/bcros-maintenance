import base64
import json
import logging
import requests
import os

processor_url = os.environ['CREATE_URL']

def pam_event_handler(event, context):
    try:
        logging.info(f"Received event: {event}")
        pubsub_message = base64.b64decode(event['data']).decode('utf-8')
        logging.info(f"Decoded message: {pubsub_message}")

        request_json = json.loads(decoded_message)

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

        seconds = int(''.join(filter(str.isdigit, requested_duration))) // 60

        payload = {
            "assignee": email,
            "entitlement": role_name,
            "duration": seconds,
            "robot": False
        }

        logging.warning(f"Constructed payload: {payload}")

        headers = {
            "Content-Type": "application/json"
        }
        response = requests.post(processor_url, json=payload, headers=headers)

        logging.warning(f"Response from target Cloud Function: {response.status_code}, {response.text}")

        if response.status_code == 200:
            return "Payload successfully sent to target Cloud Function", 200
        else:
            return f"Failed to send payload: {response.status_code}, {response.text}", 500

    except Exception as e:
        logging.error(f"Error processing Pub/Sub event: {e}")
        return f"Error: {str(e)}", 500
