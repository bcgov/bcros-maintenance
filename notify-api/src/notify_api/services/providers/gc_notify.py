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
"""This provides send email through GC Notify Service."""
import base64
import logging

from flask import current_app
from notifications_python_client import NotificationsAPIClient

from notify_api.errors import BadGatewayException
from notify_api.models import Notification


logger = logging.getLogger(__name__)


class GCNotify:
    """Send notification via GC Notify service."""

    def __init__(self, notification: Notification):
        """Construct object."""
        self.api_key = current_app.config.get('GC_NOTIFY_API_KEY')
        self.gc_notify_url = current_app.config.get('GC_NOTIFY_API_URL')
        self.gc_notify_template_id = current_app.config.get('GC_NOTIFY_TEMPLATE_ID')
        self.gc_notify_sms_template_id = current_app.config.get('GC_NOTIFY_SMS_TEMPLATE_ID')
        self.notification = notification

    def send(self):
        """Send email through GC Notify."""
        try:
            client = NotificationsAPIClient(api_key=self.api_key, base_url=self.gc_notify_url)

            email_content = {
                'email_subject': self.notification.content[0].subject,
                'email_body': self.notification.content[0].body,
            }

            if self.notification.content[0].attachments:
                for idx, attachment in enumerate(self.notification.content[0].attachments):
                    attachment_encoded = base64.b64encode(attachment.file_bytes)
                    email_content[f'attachment{idx}'] = {
                        'file': attachment_encoded.decode(),
                        'filename': attachment.file_name,
                        'sending_method': 'attach'
                    }

            # send one email at a time
            for recipient in self.notification.recipients.split(','):
                client.send_email_notification(
                    email_address=recipient,
                    template_id=self.gc_notify_template_id,
                    personalisation=email_content
                )

        except Exception as err:  # pylint: disable=broad-except # noqa F841;
            # bypass team-only API key bad request error
            if 'this recipient using a team-only API key' not in f'{err}':
                logger.error('Email GC Notify Error: %s', err)
                raise BadGatewayException(error=f'Email GC Notify Error {err}') from err
        return True

    def send_sms(self):
        """Send TEXT through GC Notify."""
        try:
            client = NotificationsAPIClient(api_key=self.api_key, base_url=self.gc_notify_url)

            for phone in self.notification.recipients.split(','):
                client.send_sms_notification(
                    phone_number=phone,
                    template_id=self.gc_notify_sms_template_id,
                    personalisation={
                        'sms_body': self.notification.content[0].body
                    })

        except Exception as err:  # pylint: disable=broad-except # noqa F841;
            logger.error('TEXT GC Notify Error: %s', err)
            raise BadGatewayException(error=f'TEXT GC Notify Error {err}') from err
        return True
