import functions_framework
from google.cloud import privilegedaccessmanager_v1
from google.cloud.privilegedaccessmanager_v1.types import CreateGrantRequest, Grant, Justification
from google.protobuf import duration_pb2
import json
import uuid

@functions_framework.http
def create_pam_grant_request(request):
    request_id = str(uuid.uuid4())
    # Extract request data (assignee, entitlement_id)
    request_json = request.get_json()

    if not request_json or 'assignee' not in request_json or 'entitlement_id' not in request_json:
        return json.dumps({'status': 'error', 'message': 'Missing required fields'}), 400

    assignee = request_json['assignee']
    entitlement_id = request_json['entitlement_id']
    project = request_json['project']
    justification = request_json['justification']

    try:
        client = privilegedaccessmanager_v1.PrivilegedAccessManagerClient()

        grant = Grant()
        just = Justification()
        just.unstructured_justification = justification
        grant.requested_duration = duration_pb2.Duration(seconds=3600)
        grant.justification = just
        grant.requester = f"user:{assignee}"

        parent = f"projects/{project}/locations/global/entitlements/{entitlement_id}"

        request = CreateGrantRequest(
            parent=parent,
            grant=grant,
            request_id=request_id
        )

        response = client.create_grant(request=request)

        return json.dumps({'status': 'success', 'response': str(response)}), 200

    except Exception as e:
        print(f"Error creating PAM grant request: {str(e)}")
        return json.dumps({'status': 'error', 'message': str(e)}), 500
