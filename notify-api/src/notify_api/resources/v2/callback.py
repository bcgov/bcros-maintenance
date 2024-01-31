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
"""API endpoints for receive callback message from GC Notify."""
from http import HTTPStatus

from flask import Blueprint
from flask_cors import cross_origin
from flask_pydantic import validate

from notify_api.models import Callback, CallbackRequest, NotificationHistory
from notify_api.utils.auth import jwt
from notify_api.utils.enums import Role
from notify_api.utils.logging import logger

bp = Blueprint("CALLBACK", __name__, url_prefix="/callback")


@bp.route("/", methods=["POST", "OPTIONS"])
@cross_origin(origin="*")
@jwt.requires_auth
@jwt.has_one_of_roles([Role.GC_NOTIFY_CALLBACK.value])
@validate()
def callback(body: CallbackRequest):  # pylint: disable=unused-argument
    """Get callback from GC Notify Service."""
    try:
        Callback.save(body)

        # find the notification history record and update the status
        history: NotificationHistory = NotificationHistory.find_by_response_id(body.id)

        # GC Notify service callback service does not distinguish between environments
        # Production history won't have records from Dev and Test.
        if history:
            history.gc_notify_status = body.status

            history.update()

    except Exception as err:  # NOQA # pylint: disable=broad-except
        logger.error(err)

    return {}, HTTPStatus.OK
