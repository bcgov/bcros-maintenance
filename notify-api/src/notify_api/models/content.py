# Copyright © 2021 Province of British Columbia
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
"""Notification Content data model."""
from __future__ import annotations

from typing import ForwardRef, List, Optional  # noqa: F401 # pylint: disable=unused-import

from pydantic import BaseModel, validator

from notify_api.utils.util import to_camel

from .attachment import Attachment, AttachmentRequest  # noqa: F401 # pylint: disable=unused-import
from .db import db  # noqa: I001


ListAttachmentRequest = ForwardRef('List[AttachmentRequest]')


class ContentRequest(BaseModel):  # pylint: disable=too-few-public-methods
    """Entity Request model for the Notification content."""

    subject: str = None
    body: str = None
    attachments: Optional[ListAttachmentRequest] = None

    @validator('subject', always=True)
    @classmethod
    def subject_not_empty(cls, v_field):
        """Valiate field is not empty."""
        if not v_field:
            raise ValueError('The email subject must not empty.')
        return v_field

    @validator('body', always=True)
    @classmethod
    def body_not_empty(cls, v_field):
        """Valiate field is not empty."""
        if not v_field:
            raise ValueError('The email body must not empty.')
        return v_field

    class Config:  # pylint: disable=too-few-public-methods
        """Config."""

        alias_generator = to_camel


class Content(db.Model):
    """Immutable Content record. Represents Content."""

    __tablename__ = 'content'

    id = db.Column(db.Integer, primary_key=True)
    subject = db.Column(db.String(2000), nullable=False)
    body = db.Column(db.Text, nullable=False)

    # parent keys
    notification_id = db.Column(db.ForeignKey('notification.id'), nullable=False)

    # relationships
    attachments = db.relationship('Attachment', order_by='Attachment.attach_order')

    @property
    def json(self):
        """Return a dict of this object, with keys in JSON format."""
        content_json = {
            'id': self.id,
            'subject': self.subject
        }

        if self.attachments:
            attachment_list = []
            for attachment in self.attachments:
                attachment_list.append(attachment.json)

            content_json['attachments'] = attachment_list

        return content_json

    @classmethod
    def create_content(cls, content: ContentRequest, notification_id: int):
        """Create notification content."""
        db_content = Content(subject=content.subject,
                             body=content.body,
                             notification_id=notification_id)
        db.session.add(db_content)
        db.session.commit()
        db.session.refresh(db_content)

        if content.attachments:
            for attachment in content.attachments:
                # save email attachment
                Attachment.create_attachment(attachment=attachment,
                                             content_id=db_content.id)
        return db_content

    def update_content(self):
        """Update content."""
        db.session.add(self)
        db.session.flush()
        db.session.commit()
        return self
