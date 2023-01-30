# Copyright © 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""API endpoints for managing a notify resource."""
import logging
from http import HTTPStatus

from flask import Blueprint, jsonify
from flask_babel import _ as babel  # noqa: N813
from flask_cors import cross_origin
from flask_pydantic import validate

from notify_api.errors import BadGatewayException, NotifyException
from notify_api.models import Notification, NotificationRequest
from notify_api.services.notify_service import NotifyService
from notify_api.utils.auth import jwt
from notify_api.utils.enums import Role


logger = logging.getLogger(__name__)

bp = Blueprint('Notify_V2', __name__, url_prefix='/notify')


@bp.route('/sms', methods=['POST'])
@cross_origin(origin='*')
@jwt.requires_auth
@jwt.has_one_of_roles([Role.SYSTEM.value, Role.SMS.value, Role.STAFF.value])
@validate()
def send_sms_notification(body: NotificationRequest):
    """Create and send SMS notification endpoint."""
    try:
        body.notify_type = Notification.NotificationType.TEXT
        notification = NotifyService().notify(body)
    except (BadGatewayException, NotifyException, Exception) as err: # NOQA # pylint: disable=broad-except
        return jsonify({'error': babel(err.error)}), err.status_code

    return jsonify(notification.json), HTTPStatus.OK


@bp.route('/resend', methods=['POST', 'OPTIONS'])
@cross_origin(origin='*')
@jwt.requires_auth
@jwt.has_one_of_roles([Role.SYSTEM.value, Role.JOB.value])
def resend_notifications():
    """Resend pending or failure notifications."""
    NotifyService().resend()

    return jsonify(), HTTPStatus.OK
