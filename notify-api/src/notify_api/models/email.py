# Copyright © 2022 Province of British Columbia
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
"""Email validator model."""
import requests
from email_validator import EmailNotValidError, validate_email
from flask import current_app
from pydantic import BaseModel, validator

from notify_api.utils.enums import MillionverifierResult


class EmailValidator(BaseModel):
    """Provides email validation."""

    email_address: str

    @validator('email_address')
    @classmethod
    def validate_email_address(cls, value):
        """Validate email address."""
        try:
            validate_email(value.strip())

            millionverifier_url = current_app.config.get('MILLIONVERIFIER_API_URL')
            millionverifier_api_key = current_app.config.get('MILLIONVERIFIER_API_KEY')

            if millionverifier_url and millionverifier_api_key:
                validation_url = f'{millionverifier_url}/?api={millionverifier_api_key}&email={value}&timeout=10'

                response = requests.get(validation_url, timeout=10)

                res_json = response.json()
                if res_json:
                    if res_json['result'] != MillionverifierResult.OK.value:
                        raise EmailNotValidError(f'{res_json["subresult"]} {res_json["error"]}')
        except EmailNotValidError as error_msg:
            raise ValueError(f'Invalid: {value} {error_msg}') from error_msg

        return True
