import logging
import os
import base64
import json
from googleapiclient.discovery import build


instance_connection_name = os.environ['DB_INSTANCE_CONNECTION_NAME']
project_number = os.environ['PROJECT_NUMBER']


def remove_iam_user(project_id, instance_name, iam_user_email):
    service = build("sqladmin", "v1beta4")
    request = service.users().delete(
        project=project_number,
        instance=instance_name.split(":")[-1],
        name=iam_user_email
    )
    response = request.execute()
    logging.warning(f"IAM user {iam_user_email} removed successfully!")
    return response

def pam_event_handler(event, context):
    try:
        logging.warning(f"Received event: {event}")
        pubsub_message = base64.b64decode(event['data']).decode('utf-8')
        logging.warning(f"Decoded message: {pubsub_message}")

        request_json = json.loads(pubsub_message)
        method_name = request_json.get('protoPayload', {}).get('methodName')
        if not method_name:
            logging.error("methodName not found in the payload")
            return "methodName not found in the Pub/Sub message payload", 400

        email = None
        if method_name == "google.cloud.privilegedaccessmanager.v1alpha.PrivilegedAccessManager.RevokeGrant":
            email = request_json.get('protoPayload', {}).get('authenticationInfo', {}).get('principalEmail')
        elif method_name == "PAMEndGrant":
            email = next(
                (
                    event.get('approved', {}).get('actor')
                    for event in request_json.get('protoPayload', {}).get('metadata', {}).get('updatedGrant', {}).get('timeline', {}).get('events', [])
                    if 'approved' in event
                ),
                None
            )

        if not email:
            logging.warning("Email not found in the event")
            return "Email not found in the Pub/Sub message payload", 400

        remove_iam_user(project_number, instance_connection_name, email)

        return f"Successfully processed the event for {email}", 200

    except KeyError as e:
        logging.error(f"Missing payload key: {str(e)}")
        return f"Missing key in the payload: {str(e)}", 400
    except Exception as e:
        logging.error(f"Failed to process the event: {str(e)}")
        return f"Failed to process the event: {str(e)}", 500
