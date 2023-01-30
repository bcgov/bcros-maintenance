"""empty message

Revision ID: 507b9240b8ed
Revises: 485e7412ac47
Create Date: 2023-01-28 13:40:13.399786

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '507b9240b8ed'
down_revision = '485e7412ac47'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table('notification_history',
                    sa.Column('id', sa.Integer(), nullable=False),
                    sa.Column('recipients', sa.String(length=2000), nullable=False),
                    sa.Column('request_date', sa.DateTime(), nullable=False),
                    sa.Column('request_by', sa.String(length=100), nullable=True),
                    sa.Column('sent_date', sa.DateTime(), nullable=True),
                    sa.Column('subject', sa.String(length=2000), nullable=False),
                    sa.Column('type_code', sa.String(length=15), nullable=False),
                    sa.Column('status_code', sa.String(length=15), nullable=False),
                    sa.Column('provider_code',  sa.String(length=15), nullable=False),
                    sa.ForeignKeyConstraint(['status_code'], ['notification_status.code'], ),
                    sa.ForeignKeyConstraint(['type_code'], ['notification_type.code'], ),
                    sa.ForeignKeyConstraint(['provider_code'], ['notification_provider.code'], ),
                    sa.PrimaryKeyConstraint('id')
                    )


def downgrade():
    op.drop_table('notification_history')
