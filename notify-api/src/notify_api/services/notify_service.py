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

"""This provides the service for email notify calls."""
import logging
from datetime import datetime

from bs4 import BeautifulSoup
from flask import current_app

from notify_api.errors import BadGatewayException, NotifyException
from notify_api.models import Notification, NotificationHistory, NotificationRequest
from notify_api.services.providers import _all_providers  # noqa: E402


logger = logging.getLogger(__name__)


class NotifyService():
    """Provides services to manages notification."""

    def __init__(self):
        """Return a Notification service instance."""

    @classmethod
    def get_provider(cls, notification: Notification) -> str:
        """Get the notify service provider."""
        if current_app.config.get('GC_NOTIFY_ENABLE') == 'True':
            if notification.type_code == Notification.NotificationType.TEXT:
                # Send TEXT through GC Notify
                return Notification.NotificationProvider.GC_NOTIFY

            # Send email through GC Notify if email body is not html
            if not bool(BeautifulSoup(notification.content[0].body, 'html.parser').find()):
                return Notification.NotificationProvider.GC_NOTIFY
        else:
            if notification.type_code == Notification.NotificationType.TEXT:
                # GC Notify is disabled, can't send TEXT through SMS
                raise BadGatewayException(error='GC Notify is not enabled.')

        return Notification.NotificationProvider.SMTP

    def notify(self, notification_request: NotificationRequest) -> NotificationHistory:
        """Send the notification."""
        try:
            notification = Notification.create_notification(notification_request)

            provider: str = self.get_provider(notification)
            if notification.type_code == Notification.NotificationType.TEXT:
                _all_providers[provider](notification).send_sms()
            else:
                _all_providers[provider](notification).send()

            # update the notification status
            notification.sent_date = datetime.utcnow()
            notification.status_code = Notification.NotificationStatus.DELIVERED
            notification.provider_code = provider
            notification.update_notification()

            # save to history
            notification_history = NotificationHistory.create_history(notification)
            notification.delete_notification()

        except (BadGatewayException, NotifyException, Exception) as err:  # NOQA # pylint: disable=broad-except
            logger.error('Send notification Error: %s', err)
            notification.sent_date = datetime.utcnow()
            notification.status_code = Notification.NotificationStatus.FAILURE

            notification.update_notification()

            raise err
        return notification_history

    def resend(self):
        """Resend the notifications."""
        try:
            notifications = Notification.find_resend_notifications()

            for notification in notifications:
                provider: str = self.get_provider(notification)
                if notification.type_code == Notification.NotificationType.TEXT:
                    _all_providers[provider](notification).send_sms()
                else:
                    _all_providers[provider](notification).send()

                # update the notification status
                notification.sent_date = datetime.utcnow()
                notification.status_code = Notification.NotificationStatus.DELIVERED
                notification.provider_code = provider
                notification.update_notification()

                # save to history
                NotificationHistory.create_history(notification)
                notification.delete_notification()

        except (BadGatewayException, NotifyException, Exception) as err:  # NOQA # pylint: disable=broad-except
            logger.error('Send notification Error: %s', err)
            notification.sent_date = datetime.utcnow()
            notification.status_code = Notification.NotificationStatus.FAILURE

            notification.update_notification()

            raise err
