import logging
import os
import base64
import json
from google.cloud.sql.connector import Connector, IPTypes
from google.cloud import secretmanager
import sqlalchemy
import pg8000

connector = Connector()

instance_connection_name = os.environ['DB_INSTANCE_CONNECTION_NAME']
username = os.environ['DB_USER']
dbname = os.environ['DB_NAME']
project_number = os.environ['PROJECT_NUMBER']
secret_id = os.environ['SECRET_ID']
secret_name = f"projects/{project_number}/secrets/{secret_id}/versions/latest"
client = secretmanager.SecretManagerServiceClient()
response = client.access_secret_version(name=secret_name)
password = response.payload.data.decode("UTF-8")


# lazy initialization of global db
db = None

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
        timeline_events = (
            request_json.get("protoPayload", {})
                        .get("metadata", {})
                        .get("updatedGrant", {})
                        .get("timeline", {})
                        .get("events", [])
        )

        email = None
        for event in timeline_events:
            if "approved" in event:
                email = event["approved"].get("actor")
                break

        if not email:
            logging.warning("Email not found in timeline's approved event")
            return f"Email not found in the Pub/Sub message payload", 400

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
