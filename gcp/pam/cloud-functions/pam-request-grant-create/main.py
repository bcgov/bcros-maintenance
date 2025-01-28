import base64
import json
import logging
import os
import uuid
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

from google.cloud import secretmanager, resourcemanager_v3, scheduler_v1
from google.cloud.sql.connector import Connector, IPTypes
from google.cloud import privilegedaccessmanager_v1
from google.iam.v1 import policy_pb2
from google.type import expr_pb2
from googleapiclient.discovery import build
import pg8000
import sqlalchemy
import functions_framework

# Environment variables
instance_connection_name = os.environ['DB_INSTANCE_CONNECTION_NAME']
username = os.environ['DB_USER']
dbname = os.environ['DB_NAME']
pubsub_topic = os.environ['PUBSUB_TOPIC']
project_number = os.environ['PROJECT_NUMBER']
project_id = os.environ['PROJECT_ID']
secret_id = os.environ['SECRET_ID']
secret_name = f"projects/{project_number}/secrets/{secret_id}/versions/latest"
region = 'northamerica-northeast1'
parent = f'projects/{project_id}/locations'

# Fetch the database password from Secret Manager
client = secretmanager.SecretManagerServiceClient()
response = client.access_secret_version(name=secret_name)
password = response.payload.data.decode("UTF-8")

# Lazy initialization of global db connection
db = None


def update_project_iam_policy_with_condition(project_id, entitlement, assignee, duration):
    client = resourcemanager_v3.ProjectsClient()
    project_name = f"projects/{project_id}"
    entitlement = f"projects/{project_id}/roles/{entitlement}"

    desired_timezone = ZoneInfo("America/Vancouver")
    current_time_utc = datetime.now(timezone.utc)
    expiration_time = (current_time_utc + timedelta(minutes=duration)).astimezone(desired_timezone).isoformat("T")

    condition = expr_pb2.Expr(
        title="Temporary Access",
        expression=f"request.time < timestamp('{expiration_time}')"
    )

    policy_request = {
        "resource": project_name,
        "options": {"requested_policy_version": 3},
    }

    policy = client.get_iam_policy(request=policy_request)

    if policy.version < 3:
        policy.version = 3

    for binding in policy.bindings:
        if entitlement in binding.role and f"user:{assignee}" in binding.members:
            if len(binding.members) > 1:
                binding.members.remove(f"user:{assignee}")
                user_removed_from_binding = True
            else:
                policy.bindings.remove(binding)
            break

    new_binding = policy_pb2.Binding(
        role=entitlement,
        members=[f"user:{assignee}"],
        condition=condition,
    )
    policy.bindings.append(new_binding)

    client.set_iam_policy(
        request={
            "resource": project_name,
            "policy": policy,
        }
    )
    logging.warning(f'Role {entitlement} assigned to user {assignee}')


def check_pam(user_email, role, project_id):

    client = privilegedaccessmanager_v1.PrivilegedAccessManagerClient()

    try:
        response = client.list_entitlements(parent=f'{parent}/global')
        user_email_lower = user_email.lower()  # Convert user_email to lowercase
        for entitlement in response:
            for eligible_user in entitlement.eligible_users:
                # Check if user_email exists in eligible_user.principals (case-insensitive)
                if any(f'{prefix}:{user_email_lower}' in principal.lower() for principal in eligible_user.principals for prefix in ['user', 'serviceaccount']):
                    for binding in entitlement.privileged_access.gcp_iam_access.role_bindings:
                        if binding.role == f'projects/{project_id}/roles/{role}':
                            return True, entitlement.max_request_duration.seconds
        return False, 0
    except Exception as e:
        return False, 0


def create_one_time_scheduler_job(project_id, topic_name, role, email, duration, robot):
    client = scheduler_v1.CloudSchedulerClient()

    unique_id = uuid.uuid4().hex
    job_name = f"pam-update-grant-job-{unique_id}"
    full_name = f"{parent}/{region}/jobs/{job_name}"

    if email.endswith(f"gserviceaccount.com"):
        email = email.replace(".gserviceaccount.com", "")

    message_data = {
        "status": "expired",
        "grant": role,
        "user": email,
        "job_name": full_name,
        "robot": robot
    }

    data_bytes = json.dumps(message_data).encode("utf-8")

    pubsub_target = scheduler_v1.PubsubTarget(
        topic_name=f"projects/{project_id}/topics/{topic_name}",
        data=data_bytes
    )

    desired_timezone = ZoneInfo("America/Vancouver")
    current_time_utc = datetime.now(timezone.utc)
    expiration_time = (current_time_utc + timedelta(minutes=duration)).astimezone(desired_timezone)

    schedule = f"{expiration_time.minute} {expiration_time.hour} {expiration_time.day} {expiration_time.month} *"
    job = scheduler_v1.Job(
        name=full_name,
        pubsub_target=pubsub_target,
        schedule=schedule,
        time_zone="America/Vancouver",
    )
    created_job = client.create_job(parent=f'{parent}/{region}', job=job)
    logging.warning(f'Created job: {created_job.name}')
    return full_name


def create_iam_user(project_id, instance_name, iam_user_email):
    service = build("sqladmin", "v1beta4")

    if iam_user_email.endswith(f"gserviceaccount.com"):
        user_name = iam_user_email.replace(".gserviceaccount.com", "")
        user_type = "CLOUD_IAM_SERVICE_ACCOUNT"
    else:
        user_name = iam_user_email
        user_type = "CLOUD_IAM_USER"

    user_body = {
        "name": user_name,
        "type": user_type
    }

    try:
        request = service.users().insert(
            project=project_id,
            instance=instance_name.split(":")[-1],
            body=user_body
        )
        response = request.execute()

        logging.warning(f"IAM user {iam_user_email} created successfully!")
        return response

    except Exception as e:
        logging.error(f"Error creating IAM user: {str(e)}")
        raise



def connect_to_instance_with_retries(retries=5, delay=2) -> sqlalchemy.engine.base.Engine:
    for attempt in range(retries):
        try:
            connector = Connector()

            def getconn() -> pg8000.dbapi.Connection:
                return connector.connect(
                    instance_connection_string=instance_connection_name,
                    driver="pg8000",
                    user=username,
                    password=password,
                    db=dbname,
                    ip_type=IPTypes.PUBLIC,
                )

            engine = sqlalchemy.create_engine(
                "postgresql+pg8000://",
                creator=getconn,
                pool_size=5,
                max_overflow=2,
                pool_timeout=30,
                pool_recycle=1800,
            ).execution_options(isolation_level="AUTOCOMMIT")

            logging.warning("Database connection successfully established!")
            return engine

        except Exception as e:
            logging.warning(
                f"Database connection attempt {attempt + 1} failed. Retrying in {delay} seconds... Error: {str(e)}"
            )
            time.sleep(delay)

    raise Exception("Failed to connect to the database after multiple attempts.")


@functions_framework.http
def create_pam_grant_request(request):
    try:
        logging.warning(f"Request body: {request.get_data(as_text=True)}")
        request_json = request.get_json()

        if not request_json or 'assignee' not in request_json or 'entitlement' not in request_json or 'duration' not in request_json or 'permissions' not in request_json:
            return json.dumps({'status': 'error', 'message': 'Missing required fields'}), 400

        assignee = request_json['assignee']
        entitlement = request_json['entitlement']
        duration = request_json['duration']
        robot = request_json['robot']
        permissions = request_json['permissions']

        pam = check_pam(assignee, entitlement, project_id)
        duration = min(pam[1] / 60, duration)

        if not pam[0]:
            return json.dumps({'status': 'error', 'message': 'Unauthorized: User is not part of the project'}), 401

        if robot:
            update_project_iam_policy_with_condition(project_id, entitlement, assignee, duration)
        create_iam_user(project_number, instance_connection_name, assignee)
        create_one_time_scheduler_job(project_id, pubsub_topic, entitlement, assignee, duration, robot)

        global db
        if not db:
            db = connect_to_instance_with_retries()

        with db.connect() as conn:
            if assignee.endswith(f"gserviceaccount.com"):
                assignee = assignee.replace(".gserviceaccount.com", "")
            grant_readonly_statement = f"GRANT {permissions} TO \"{assignee}\";"
            conn.execute(sqlalchemy.text(grant_readonly_statement))

        return json.dumps({'status': 'success', 'message': 'PAM grant request processed successfully'}), 200

    except Exception as e:
        logging.error(f"Error creating PAM grant request: {str(e)}")
        return json.dumps({'status': 'error', 'message': str(e)}), 500
