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
import warnings
from datetime import datetime

import requests
from bs4 import BeautifulSoup, MarkupResemblesLocatorWarning
from flask import current_app

from notify_api.errors import BadGatewayException, NotifyException
from notify_api.models import (
    Notification,
    NotificationHistory,
    NotificationRequest,
    NotificationSendResponses,
    SafeList,
)
from notify_api.services.providers import _all_providers  # noqa: E402
from notify_api.utils.logging import logger

warnings.filterwarnings("ignore", category=MarkupResemblesLocatorWarning, module="bs4")


class NotifyService:
    """Provides services to manages notification."""

    def __init__(self):
        """Return a Notification service instance."""

    @classmethod
    def get_provider(cls, notification: Notification) -> str:
        """Get the notify service provider."""
        if current_app.config.get("GC_NOTIFY_ENABLE") == "True":
            if notification.type_code == Notification.NotificationType.TEXT:
                # Send TEXT through GC Notify
                return Notification.NotificationProvider.GC_NOTIFY

            # Send email through GC Notify if email body is not html
            if not bool(BeautifulSoup(notification.content[0].body, "html.parser").find()):
                return Notification.NotificationProvider.GC_NOTIFY
        else:
            if notification.type_code == Notification.NotificationType.TEXT:
                # GC Notify is disabled, can't send TEXT through SMS
                raise BadGatewayException(error="GC Notify is not enabled.")

        return Notification.NotificationProvider.SMTP

    def notify(  # pylint: disable=too-many-branches
        self, notification_request: NotificationRequest, token=None
    ) -> NotificationHistory:
        """Send the notification."""
        try:
            notification = Notification.create_notification(notification_request)

            provider: str = self.get_provider(notification)

            is_safe_to_send = True

            # Email must set in safe list of Dev and Test environment
            if current_app.config.get("DEVELOPMENT"):
                recipients = [
                    r.strip() for r in notification.recipients.split(",") if SafeList.is_in_safe_list(r.lower().strip())
                ]
                unsafe_recipients = [r for r in notification.recipients.split(",") if r.strip() not in recipients]
                if unsafe_recipients:
                    logger.info("%s are not in the safe list", ",".join(unsafe_recipients))
                if not recipients:
                    is_safe_to_send = False
                else:
                    notification.recipients = ",".join(recipients)

            responses: NotificationSendResponses = None
            notification.status_code = Notification.NotificationStatus.SENT

            if is_safe_to_send:
                if notification.type_code == Notification.NotificationType.TEXT:
                    responses = _all_providers[provider](notification).send_sms()
                else:
                    if current_app.config.get("DEPLOYMENT_PLATFORM") == "GCP":
                        # GCP environment can't send the email by SMTP
                        if provider == Notification.NotificationProvider.SMTP:
                            # Forward the email to OCP notification API
                            notification.status_code = Notification.NotificationStatus.FORWARDED
                            self.forward_to_ocp(notification_request, token)
                        else:
                            responses = _all_providers[provider](notification).send()

            # update the notification status
            notification.sent_date = datetime.utcnow()
            notification.provider_code = provider
            notification.update_notification()

            if responses:
                for response in responses.recipients:
                    # save to history as per recipient
                    notification_history = NotificationHistory.create_history(
                        notification, response.recipient, response.response_id
                    )
            else:
                notification_history = NotificationHistory.create_history(notification)

            notification.delete_notification()

        except (
            BadGatewayException,
            NotifyException,
            Exception,
        ) as err:  # NOQA # pylint: disable=broad-except
            logger.error("Send notification Error: %s", err)
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

                responses: NotificationSendResponses = None

                if notification.type_code == Notification.NotificationType.TEXT:
                    responses = _all_providers[provider](notification).send_sms()
                else:
                    responses = _all_providers[provider](notification).send()

                # update the notification status
                notification.sent_date = datetime.utcnow()
                notification.status_code = Notification.NotificationStatus.SENT
                notification.provider_code = provider
                notification.update_notification()

                if responses:
                    for response in responses.recipients:
                        # save to history as per recipient
                        NotificationHistory.create_history(notification, response.recipient, response.response_id)
                else:
                    NotificationHistory.create_history(notification)

                notification.delete_notification()

        except (
            BadGatewayException,
            NotifyException,
            Exception,
        ) as err:  # NOQA # pylint: disable=broad-except
            logger.error("Send notification Error: %s", err)
            notification.sent_date = datetime.utcnow()
            notification.status_code = Notification.NotificationStatus.FAILURE

            notification.update_notification()

            raise err

    @classmethod
    def forward_to_ocp(cls, email: NotificationRequest, token: str):
        """Forward notification to OCP notification API to using SMTP email service."""
        try:
            response = requests.post(
                current_app.config.get("NOTIFY_API"),
                json=email.dict(),
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {token}",
                },
                timeout=600,
            )

            # Handling the response
            if response.status_code != 200:
                # Request failed
                logger.error("Forward notification Error: %s", response.text)
            else:
                logger.info("Forward notification Response: %s", response.text)

        except requests.exceptions.RequestException as err:  # NOQA # pylint: disable=broad-except
            logger.error("Forward notification Error: %s", err)

            raise err
