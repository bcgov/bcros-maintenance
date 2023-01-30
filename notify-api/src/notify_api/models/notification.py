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
"""Notification data model."""
from datetime import datetime
from enum import auto
from typing import Optional

import phonenumbers
from email_validator import EmailNotValidError, validate_email
from pydantic import BaseModel, validator

from notify_api.utils.base import BaseEnum
from notify_api.utils.util import to_camel

from .content import Content, ContentRequest
from .db import db  # noqa: I001


class NotificationRequest(BaseModel):  # pylint: disable=too-few-public-methods
    """Notification model for resquest."""

    recipients: str = None
    request_by: str = None
    notify_type: Optional[str] = None
    content: ContentRequest = None

    @validator('recipients', always=True)
    @classmethod
    def validate_recipients(cls, v_field):
        """Validate recipients."""
        if not v_field:
            raise ValueError('The recipients must not empty')

        for recipient in v_field.split(','):
            try:
                parsed_phone = phonenumbers.parse(recipient)
                if not phonenumbers.is_valid_number(parsed_phone):
                    raise ValueError(f'Invalid recipient: {recipient}.')
            except phonenumbers.NumberParseException:
                try:
                    validate_email(recipient.strip())
                except EmailNotValidError as error_msg:
                    raise ValueError(f'Invalid recipient: {recipient}.') from error_msg

        return v_field

    class Config:  # pylint: disable=too-few-public-methods
        """Config."""

        alias_generator = to_camel


class Notification(db.Model):
    """Immutable Notification record. Represents Notification."""

    class NotificationType(BaseEnum):
        """Enum for the Notification Type."""

        EMAIL = auto()
        TEXT = auto()

    class NotificationStatus(BaseEnum):
        """Enum for the Notification Status."""

        PENDING = auto()
        DELIVERED = auto()
        FAILURE = auto()

    class NotificationProvider(BaseEnum):
        """Enum for the Notification Provider."""

        SMTP = auto()
        GC_NOTIFY = auto()

    __tablename__ = 'notification'

    id = db.Column(db.Integer, primary_key=True)
    recipients = db.Column(db.String(2000), nullable=False)
    request_date = db.Column(db.DateTime(timezone=True), default=datetime.utcnow, nullable=True)
    request_by = db.Column(db.String(100), nullable=True)
    sent_date = db.Column(db.DateTime(timezone=True), default=datetime.utcnow, nullable=True)
    type_code = db.Column(db.Enum(NotificationType), default=NotificationType.EMAIL)
    status_code = db.Column(db.Enum(NotificationStatus), default=NotificationStatus.PENDING)
    provider_code = db.Column(db.Enum(NotificationProvider), nullable=True)

    # relationships
    content = db.relationship('Content')

    @property
    def json(self) -> dict:
        """Return a dict of this object, with keys in JSON format."""
        notification_json = {
            'id': self.id,
            'recipients': self.recipients,
            'requestDate': self.request_date.isoformat(),
            'requestBy': self.request_by,
            'sentDate': self.request_date.isoformat(),
            'notifyType': self.type_code.name or '',
            'notifyStatus': self.status_code.name or '',
            'notifyProvider': self.provider_code.name if self.provider_code else '',
        }

        notification_json['content'] = self.content[0].json

        return notification_json

    @classmethod
    def find_notification_by_id(cls, identifier: int = None):
        """Return a Notification by the id."""
        notification = None
        if identifier:
            notification = cls.query.filter_by(id=identifier).one_or_none()

        return notification

    @classmethod
    def find_notifications_by_status(cls, status: str = None):
        """Return all Notifications by the status."""
        notifications = None
        if status:
            notifications = cls.query.filter_by(status_code=status).all()
        return notifications

    @classmethod
    def find_resend_notifications(cls):
        """Return all Notifications that need to resend."""
        resend_statuses = (Notification.NotificationStatus.PENDING.value, Notification.NotificationStatus.FAILURE.value)

        notifications = cls.query.\
            filter(Notification.status_code.in_(resend_statuses)).all()
        return notifications

    @classmethod
    def create_notification(cls, notification: NotificationRequest):
        """Create notification."""
        db_notification = Notification(recipients=notification.recipients,
                                       request_by=notification.request_by,
                                       type_code=notification.notify_type)
        db.session.add(db_notification)
        db.session.commit()
        db.session.refresh(db_notification)

        # save email content
        Content.create_content(content=notification.content,
                               notification_id=db_notification.id)

        return db_notification

    def update_notification(self):
        """Update notification."""
        db.session.add(self)
        db.session.flush()
        db.session.commit()

        return self

    def delete_notification(self):
        """Delete notification content."""
        self.content[0].delete_content()
        db.session.delete(self)
        db.session.commit()
