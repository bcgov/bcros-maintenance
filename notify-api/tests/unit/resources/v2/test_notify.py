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
"""The Unit Test for the API."""
from http import HTTPStatus
from unittest.mock import patch

from notify_api.errors import NotifyException
from notify_api.services.notify_service import NotifyService
from notify_api.utils.enums import Role
from tests.factories.content import ContentFactory
from tests.factories.jwt import create_header
from tests.factories.notification import NotificationFactory


def test_invaild_roles(session, app, client, jwt):  # pylint: disable=unused-argument
    """Assert the test the role validation."""
    headers = create_header(jwt, [Role.PUBLIC_USER.value], **{'Accept-Version': 'v2'})
    res = client.post('/api/v2/notify/sms', headers=headers)
    assert res.status_code == HTTPStatus.UNAUTHORIZED


def test_find_by_invaild_input(session, app, client, jwt):  # pylint: disable=unused-argument
    """Assert the test can retrieve notification details with status."""
    headers = create_header(jwt, [Role.SYSTEM.value], **{'Accept-Version': 'v2'})
    res = client.get('/api/v2/notify/', headers=headers)
    assert res.status_code == HTTPStatus.NOT_FOUND

    res = client.get('/api/v2/notify', headers=headers)
    assert res.status_code == HTTPStatus.NOT_FOUND


def test_send_sms(session, app, client, jwt, monkeypatch):  # pylint: disable=unused-argument, too-many-arguments
    """Assert the test can create notification."""
    headers = create_header(jwt, [Role.SYSTEM.value], **{'Accept-Version': 'v2'})
    for notification_data in list(NotificationFactory.RequestData):
        notification = NotificationFactory.create_model(session, notification_info=notification_data)
        ContentFactory.create_model(session, notification.id, content_info=notification_data['content'])

        with patch.object(NotifyService, 'notify', return_value=notification):
            res = client.post('/api/v2/notify/sms', json=notification_data, headers=headers)
            assert res.status_code == HTTPStatus.OK
            assert notification_data['recipients'] == res.json['recipients']
            assert notification_data['content']['subject'] == res.json['content']['subject']


def test_send_sms_with_bad_data(session, app, jwt, client):  # pylint: disable=unused-argument
    """Assert the test can not be create notification."""
    headers = create_header(jwt, [Role.SYSTEM.value], **{'Accept-Version': 'v2'})
    for notification_data in list(NotificationFactory.RequestBadData):
        res = client.post('/api/v2/notify/sms', json=notification_data, headers=headers)
        assert res.status_code == HTTPStatus.BAD_REQUEST


def test_send_sms_exception(session, app, jwt, client):  # pylint: disable=unused-argument
    """Assert the test can not be create notification."""
    with patch.object(NotifyService, 'notify', side_effect=NotifyException(error='mocked error', status_code=500)):
        headers = create_header(jwt, [Role.SYSTEM.value], **{'Accept-Version': 'v2'})
        res = client.post('/api/v2/notify/sms', json=NotificationFactory.RequestData.REQUEST_1, headers=headers)
        assert res.status_code == HTTPStatus.INTERNAL_SERVER_ERROR
