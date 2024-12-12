import logging
import os
import base64
import json
from google.cloud.sql.connector import Connector, IPTypes
from google.cloud import secretmanager
import sqlalchemy
import pg8000
from googleapiclient.discovery import build
from datetime import datetime, timedelta, timezone
from google.cloud import scheduler_v1
from zoneinfo import ZoneInfo

connector = Connector()

instance_connection_name = os.environ['DB_INSTANCE_CONNECTION_NAME']
username = os.environ['DB_USER']
dbname = os.environ['DB_NAME']
project_number = os.environ['PROJECT_NUMBER']
project_id = os.environ['PROJECT_ID']
secret_id = os.environ['SECRET_ID']
secret_name = f"projects/{project_number}/secrets/{secret_id}/versions/latest"
client = secretmanager.SecretManagerServiceClient()
response = client.access_secret_version(name=secret_name)
password = response.payload.data.decode("UTF-8")


# lazy initialization of global db
db = None

def create_one_time_scheduler_job(project_id, topic_name, role, email):
    client = scheduler_v1.CloudSchedulerClient()

    parent = f"projects/{project_id}/locations/northamerica-northeast1"

    message_data = {
        "status": "expired",
        "grant": role,
        "user": email
    }

    data_bytes = json.dumps(message_data).encode("utf-8")

    pubsub_target = scheduler_v1.PubsubTarget(
        topic_name=f"projects/{project_id}/topics/{topic_name}",
        data=data_bytes
    )

    desired_timezone = ZoneInfo("America/Vancouver")
    current_time_utc = datetime.now(timezone.utc)  # Correct usage
    expiration_time = (current_time_utc + timedelta(hours=1)).astimezone(desired_timezone)

    schedule = f"{expiration_time.minute} {expiration_time.hour} {expiration_time.day} {expiration_time.month} *"
    job = scheduler_v1.Job(
        name = f"projects/{project_id}/locations/northamerica-northeast1/jobs/pam-update-grant-job",
        pubsub_target=pubsub_target,
        schedule=schedule,
        time_zone="America/Vancouver",
    )
    client.create_job(parent=parent, job=job)



def create_iam_user(project_id, instance_name, iam_user_email):
    service = build("sqladmin", "v1beta4")

    user_body = {
        "name": iam_user_email,
        "type": "CLOUD_IAM_USER"
    }

    request = service.users().insert(
        project=project_id,
        instance=instance_name.split(":")[-1],
        body=user_body
    )
    response = request.execute()

    logging.warning(f"IAM user {iam_user_email} created successfully!")
    return response


def connect_to_instance() -> sqlalchemy.engine.base.Engine:
    connector = Connector()

    def getconn() -> pg8000.dbapi.Connection:
        return connector.connect(
                instance_connection_string=instance_connection_name,
                driver="pg8000",
                user=username,
                password=password,
                db=dbname,
                ip_type  = IPTypes.PUBLIC
            )

    return sqlalchemy.create_engine(
            "postgresql+pg8000://",
            creator      = getconn,
            pool_size    = 5,
            max_overflow = 2,
            pool_timeout = 30,
            pool_recycle = 1800
        ).execution_options(isolation_level="AUTOCOMMIT")

db = None

def pam_event_handler(event, context):
    try:
        # Log the entire event for debugging
        logging.warning(f"Received event: {event}")

        # Decode the Pub/Sub message data
        pubsub_message = base64.b64decode(event['data']).decode('utf-8')
        logging.warning(f"Decoded message: {pubsub_message}")

        request_json = json.loads(pubsub_message)

        # Attempt to locate the email in the timeline's approved event
        binding_deltas = (
            request_json.get("protoPayload", {})
                        .get("serviceData", {})
                        .get("policyDelta", {})
                        .get("bindingDeltas", [])
        )

        email = None
        role = None

        for delta in binding_deltas:
                if delta.get("action") == "ADD" and "condition" in delta:
                    role = delta.get("role", "")
                    member = delta.get("member", "")
                    if member.startswith("user:"):
                        email = member[len("user:"):]
                        break

        if not email:
            logging.warning("Email not found in timeline's approved event")
            return f"Email not found in the Pub/Sub message payload", 400

        create_iam_user(project_number, instance_connection_name, email)
        create_one_time_scheduler_job(project_id, 'pam-revoke-topic', role, email)

        # lazy init within request context
        global db
        if not db:
            db = connect_to_instance()

        with db.connect() as conn:
            grant_readonly_statement = f"GRANT readonly TO \"{email}\";"
            conn.execute(sqlalchemy.text(grant_readonly_statement))
            # audit_ext_statement = "CREATE EXTENSION pgaudit;"
            # conn.execute(sqlalchemy.text(audit_ext_statement))

        return f"Successfully granted read-only access to {email}", 200

    except KeyError as e:
        logging.error(f"Missing payload key: {str(e)}")
        return f"Missing key in the payload: {str(e)}", 400
    except Exception as e:
        logging.error(f"Failed to grant access: {str(e)}")
        return f"Failed to grant access: {str(e)}", 500
