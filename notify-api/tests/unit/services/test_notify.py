# Copyright © 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""The Unit Test for the Service."""
from http import HTTPStatus
from unittest.mock import patch

import pytest

from notify_api.errors import BadGatewayException, NotifyException
from notify_api.models.notification import Notification, NotificationRequest
from notify_api.services.notify_service import NotifyService
from notify_api.services.providers.email_smtp import EmailSMTP
from notify_api.services.providers.gc_notify import GCNotify
from tests.factories.content import ContentFactory
from tests.factories.notification import NotificationFactory


def test_get_provider(session):  # pylint: disable=unused-argument
    """Assert the test can get provider."""
    for notification_data in list(NotificationFactory.RequestProviderData):
        notification = NotificationFactory.create_model(session, notification_info=notification_data['data'])
        ContentFactory.create_model(session, notification.id, content_info=notification_data['data']['content'])

        service = NotifyService()
        result = service.get_provider(notification)
        assert result is not None
        assert result == notification_data['provider']


def test_get_provider_gc_notify_disable(app, session, monkeypatch):  # pylint: disable=unused-argument
    """Assert the test can create notification."""
    app.config['GC_NOTIFY_ENABLE'] = 'False'
    notification = NotificationFactory.create_model(session,
                                                    NotificationFactory.RequestProviderData.REQUEST_PROVIDER_1['data'])
    ContentFactory.create_model(session,
                                notification.id,
                                NotificationFactory.RequestProviderData.REQUEST_PROVIDER_1['data']['content'])
    notification.type_code = Notification.NotificationType.TEXT

    with pytest.raises(BadGatewayException) as exception:
        service = NotifyService()
        service.get_provider(notification)

    assert exception.value.error == 'GC Notify is not enabled.'
    assert exception.value.status_code == HTTPStatus.BAD_GATEWAY

    notification = NotificationFactory.create_model(session,
                                                    NotificationFactory.RequestProviderData.REQUEST_PROVIDER_1['data'])
    ContentFactory.create_model(session,
                                notification.id,
                                NotificationFactory.RequestProviderData.REQUEST_PROVIDER_1['data']['content'])

    service = NotifyService()
    result = service.get_provider(notification)

    assert result is not None
    assert result == Notification.NotificationProvider.SMTP

    app.config['GC_NOTIFY_ENABLE'] = 'True'


def test_notify_by_email(session, monkeypatch):  # pylint: disable=unused-argument
    """Assert the test can create notification."""
    with patch.object(EmailSMTP, 'send', return_value=True), \
         patch.object(GCNotify, 'send', return_value=True):
        service = NotifyService()
        notification = NotificationRequest(**NotificationFactory.RequestProviderData.REQUEST_PROVIDER_2['data'])
        result = service.notify(notification)
        assert result is not None
        assert result.recipients == NotificationFactory.RequestData.REQUEST_1['recipients']


def test_notify_by_sms(session, monkeypatch):  # pylint: disable=unused-argument
    """Assert the test can create sms notification."""
    with patch.object(GCNotify, 'send_sms', return_value=True):
        service = NotifyService()
        notification = NotificationRequest(**NotificationFactory.RequestProviderData.REQUEST_PROVIDER_3['data'])
        notification.notify_type = Notification.NotificationType.TEXT
        result = service.notify(notification)
        assert result is not None
        assert result.recipients == NotificationFactory.RequestProviderData.REQUEST_PROVIDER_3['data']['recipients']


def test_notify_badgatewayexception(app, session):  # pylint: disable=unused-argument
    """Assert the test can create notification with BAD_GATEWAY exception."""
    app.config['GC_NOTIFY_API_URL'] = ''
    app.config['MAIL_SERVER'] = ''

    with pytest.raises(BadGatewayException) as exception:
        NotifyService().notify(NotificationRequest(**NotificationFactory.RequestData.REQUEST_1))

    assert exception.value.status_code == HTTPStatus.BAD_GATEWAY


def test_notify_notifyexception(app, session):  # pylint: disable=unused-argument
    """Assert the test can create notification with Notify exception."""
    with patch.object(EmailSMTP, 'send', side_effect=NotifyException(error='mocked error', status_code=404)), \
         patch.object(GCNotify, 'send', side_effect=NotifyException(error='mocked error', status_code=404)), \
         patch.object(GCNotify, 'send_sms', side_effect=NotifyException(error='mocked error', status_code=404)):
        with pytest.raises(NotifyException) as exception:
            NotifyService().notify(NotificationRequest(**NotificationFactory.RequestData.REQUEST_1))

        assert exception.value.error == 'mocked error'


def test_notify_exception(app, session):  # pylint: disable=unused-argument
    """Assert the test can create notification with Notify exception."""
    with patch.object(EmailSMTP, 'send', side_effect=Exception('mocked error')), \
         patch.object(GCNotify, 'send', side_effect=Exception('mocked error')), \
         patch.object(GCNotify, 'send_sms', side_effect=Exception('mocked error')):
        with pytest.raises(Exception) as exception:
            NotifyService().notify(NotificationRequest(**NotificationFactory.RequestData.REQUEST_1))

        assert exception.value.args[0] == 'mocked error'
