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
"""API endpoints for validate email address."""
import logging
from http import HTTPStatus

from flask import Blueprint
from flask_cors import cross_origin
from flask_pydantic import validate

from notify_api.models import SafeList, SafeListRequest
from notify_api.utils.auth import jwt
from notify_api.utils.enums import Role


logger = logging.getLogger(__name__)

bp = Blueprint('SAFE_LIST', __name__, url_prefix='/safe_list')


@bp.route('/', methods=['POST', 'OPTIONS'])
@cross_origin(origin='*')
@jwt.requires_auth
@jwt.has_one_of_roles([Role.SYSTEM.value, Role.STAFF.value])
@validate()
def safe_list(body: SafeListRequest):  # pylint: disable=unused-argument
    """Add email(s) to safe list."""
    for email in body.email:
        try:
            SafeList.add_email(email.lower().strip())
        except (Exception) as err: # NOQA # pylint: disable=broad-except
            logger.debug(err)

    return {}, HTTPStatus.OK
