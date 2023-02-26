"""add safe list

Revision ID: ab887fe3402f
Revises: 507b9240b8ed
Create Date: 2023-02-17 17:23:54.093183

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'ab887fe3402f'
down_revision = '507b9240b8ed'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table('safe_list',
                    sa.Column('id', sa.Integer(), nullable=False),
                    sa.Column('email', sa.String(length=2000), nullable=False),
                    sa.PrimaryKeyConstraint('id'),
                    sa.UniqueConstraint('email')
                    )


def downgrade():
    op.drop_table('safe_list')
