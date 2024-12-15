import logging
import os
import base64
import json
from googleapiclient.discovery import build
from google.cloud import resourcemanager_v3, scheduler_v1


instance_connection_name = os.environ['DB_INSTANCE_CONNECTION_NAME']
project_number = os.environ['PROJECT_NUMBER']


def remove_iam_binding(project_id, role, email):
    client = resourcemanager_v3.ProjectsClient()
    project_name = f"projects/{project_id}"
    def modify_policy_remove_member(policy):
        """Callback to remove a member from a specific role."""
        for binding in policy.bindings:
            if role in binding.role and f"user:{email}" in binding.members and binding.condition:
                binding.members.remove(f"user:{email}")
                if not binding.members:
                    policy.bindings.remove(binding)

        return policy

    try:
        policy_request = {
                "resource": project_name,
                "options": {"requested_policy_version": 3},
        }

        policy = client.get_iam_policy(request=policy_request)
        updated_policy = modify_policy_remove_member(policy)
        client.set_iam_policy(
            request={"resource": project_name, "policy": updated_policy}
        )
        logging.info(f"IAM policy updated for project {project_id}")
    except Exception as e:
        logging.error(f"Error removing IAM binding: {str(e)}")
        raise


def remove_scheduler_job(full_job_name):
    client = scheduler_v1.CloudSchedulerClient()

    try:
        client.delete_job(name=full_job_name)
        logging.info(f"Scheduler job {full_job_name} deleted successfully!")
    except Exception as e:
        logging.error(f"Error deleting scheduler job {full_job_name}: {str(e)}")
        raise


def remove_iam_user(project_id, instance_name, iam_user_email):
    service = build("sqladmin", "v1beta4")
    request = service.users().delete(
        project=project_number,
        instance=instance_name.split(":")[-1],
        name=iam_user_email
    )
    response = request.execute()
    logging.info(f"IAM user {iam_user_email} removed successfully!")
    return response

def pam_event_handler(event, context):
    try:
        logging.info(f"Received event: {event}")
        pubsub_message = base64.b64decode(event['data']).decode('utf-8')
        logging.info(f"Decoded message: {pubsub_message}")

        request_json = json.loads(pubsub_message)

        email = request_json.get('user', {})

        if not email:
            logging.warning("Email not found in the event")
            return "Email not found in the Pub/Sub message payload", 400

        remove_iam_user(project_number, instance_connection_name, email)

        grant = request_json.get('grant', {})

        if not grant:
            logging.warning("Role grant not found in the event")
            return "Role not found in the Pub/Sub message payload", 400

        robot = request_json.get('robot', {})

        if robot:
            remove_iam_binding(project_number, grant, email)

        job_name = request_json.get('job_name', {})

        remove_scheduler_job(job_name)

        return f"Successfully processed the event for {email}", 200

    except KeyError as e:
        logging.error(f"Missing payload key: {str(e)}")
        return f"Missing key in the payload: {str(e)}", 400
    except Exception as e:
        logging.error(f"Failed to process the event: {str(e)}")
        return f"Failed to process the event: {str(e)}", 500
