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
"""Enum definitions."""
from notify_api.utils.base import BaseEnum


class Role(BaseEnum):
    """User Role."""

    SYSTEM = 'system'
    STAFF = 'staff'
    PUBLIC_USER = 'public_user'
    SMS = 'sms'
    JOB = 'job'
    INVALID = 'invalid'


class MillionverifierResult(BaseEnum):
    """The result of email verification."""

    OK = 'ok'
    CATCH_ALL = 'catch_all'
    UNKNOWN = 'unknown'
    ERROR = 'error'
    DISPOSABLE = 'disposable'
    INVALID = 'invalid'
